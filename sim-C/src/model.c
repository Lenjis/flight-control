#include "model.h"  //库函数在其中声明
#include <stdio.h>
#include <math.h>
static double S = 3.6,  // [机翼面积]|[平方米]
    L = 6.0,            // [翼展]|[米]
    BA = 0.6,           // [平均气动弦长]|[米]
    Ixx = 0, Iyy = 0, Izz = 0, Ixy = 0, g = 9.8, mass_net = 17;

static void uav_density(double H, double VT, double *ru, double *mach);
static double uav_interp1(double *A, double Dim1[], int Len1, double X1);
static double uav_interp2(double *A, double Dim1[], int Len1, double X1,
                          double Dim2[], int Len2, double X2);
static double uav_interp3(double *A, double Dim1[], int Len1, double X1,
                          double Dim2[], int Len2, double X2, double Dim3[],
                          int Len3, double X3);
static int uav_find(double A[], double X, int len);

void model6dof(double t, double x[], double u[], double dx[], int dim) {
    double Vt, alpha, beta, phi, theta, psi, P, Q, R, PN, PE, H;
    double dVt, dalpha, dbeta, dphi, dtheta, dpsi, dP, dQ, dR, dPN, dPE, dH;
    double ele, ail, rud, eng;
    double alpha_deg, beta_deg;
    double salpha, sbeta, sphi, stheta, spsi, calpha, cbeta, cphi, ctheta, cpsi;

    double ru, mach, qs;

    // [VT,alpha,beta]  ----- airspeed(m/s), angle of attack(rad), angle of sideslip(rad)
    // [wx,wy,wz]       ----- roll rate(rad/s),yaw rate(rad/s),pitch rate(rad/s)
    // [theta,gama,psi] ----- pitch angle,roll angle,heading angle(rad)
    // [alt,lon,lat]    ----- aircraft altitude(m),longitude(rad),latitude(rad)
    Vt = x[0];
    alpha = x[1];
    beta = x[2];
    phi = x[3];
    theta = x[4];
    psi = x[5];
    P = x[6];
    Q = x[7];
    R = x[8];
    PN = x[9];
    PE = x[10];
    H = x[11];

    // control input
    // ---------------
    // elevator, aileron, rudder
    ele = u[0];  // elevator deflection angle [deg]
    ail = u[1];  // aileron  deflection angle [deg]
    rud = u[2];  // aileron  deflection angle [deg]
    eng = u[3];  // engine input
    // ------------------------------------------------

    alpha_deg = alpha * 57.3;
    beta_deg = beta * 57.3;

    if (Vt < 0.1) Vt = 0.1;
    uav_density(H, Vt, &ru, &mach);  // [air density] [mach number]
    qs = S * (ru * Vt * Vt / 2);     // [Dynamic pressure](kg/m^2)

    salpha = sin(alpha);
    sbeta = sin(beta);
    calpha = cos(alpha);
    cbeta = cos(beta);

    sphi = sin(phi);
    stheta = sin(theta);
    spsi = sin(psi);
    cphi = cos(phi);
    ctheta = cos(theta);
    cpsi = cos(psi);

    dVt = 0;
    dalpha = 0;
    dbeta = 0;
    dphi = 0;
    dtheta = 0;
    dpsi = 0;
    dP = 0;
    dQ = 0;
    dR = 0;
    dPN = 0;
    dPE = 0;
    dH = 0;

    dx[0] = dVt;
    dx[1] = dalpha;
    dx[2] = dbeta;
    dx[3] = dphi;
    dx[4] = dtheta;
    dx[5] = dpsi;
    dx[6] = dP;
    dx[7] = dQ;
    dx[8] = dR;
    dx[9] = dPN;
    dx[10] = dPE;
    dx[11] = dH;
}

// ============================================================================
// pdensity
// Return air density and mach number
// ============================================================================
static void uav_density(double H, double VT, double *ru, double *mach) {
    double temp;

    if (H < 11000.0) {
        temp = 1.0 - 0.0225569 * H / 1000.0;
        *ru = 0.12492 * 9.8 * exp(4.255277 * log(temp));
        *mach = VT / 340.375 / sqrt(temp);
    } else {
        temp = 11.0 - H / 1000.0;
        *ru = 0.03718 * 9.8 * exp(temp / 6.318);
        *mach = VT / 295.188;
    }
}

//=============================================================================
// uav_cx
//=============================================================================
static void uav_Cx(double alpha_deg, double *Cx) {
    static double IDX_alpha[14] = {-6.0, -4.0, -2.0, 0.0,  2.0,  4.0,  6.0,
                                   8.0,  10.0, 12.0, 14.0, 16.0, 18.0, 20.0};
    static double TBL_Cx[14] = {0.03931, 0.03863, 0.04155, 0.04847, 0.05841,
                                0.07079, 0.08530, 0.10213, 0.11742, 0.16796,
                                0.23854, 0.29419, 0.37927, 0.47888};
    *Cx = uav_interp1(TBL_Cx, IDX_alpha, 14, alpha_deg);
}
//=============================================================================
// uav_interp1
//=============================================================================
static double uav_interp1(double *A, double Dim1[], int Len1, double X1) {
    int r;
    double DA, Y;

    r = uav_find(Dim1, X1, Len1);

    DA = (X1 - Dim1[r]) / (Dim1[r + 1] - Dim1[r]);
    Y = A[r] + (A[r + 1] - A[r]) * DA;
    return (Y);
}
//=============================================================================
// uav_interp2
//=============================================================================
static double uav_interp2(double *A, double Dim1[], int Len1, double X1,
                          double Dim2[], int Len2, double X2) {
    int r;
    double *SUB1, DA, V, W, Y;

    r = uav_find(Dim1, X1, Len1);

    DA = (X1 - Dim1[r]) / (Dim1[r + 1] - Dim1[r]);

    SUB1 = A + Len2 * r;
    V = uav_interp1(SUB1, Dim2, Len2, X2);
    SUB1 = A + Len2 * (r + 1);
    W = uav_interp1(SUB1, Dim2, Len2, X2);

    Y = V + (W - V) * DA;
    return (Y);
}
//=============================================================================
// uav_interp3
//=============================================================================
static double uav_interp3(double *A, double Dim1[], int Len1, double X1,
                          double Dim2[], int Len2, double X2, double Dim3[],
                          int Len3, double X3) {
    static int r;
    static double *SUB2, DA, V, W, Y;

    r = uav_find(Dim1, X1, Len1);

    DA = (X1 - Dim1[r]) / (Dim1[r + 1] - Dim1[r]);

    SUB2 = A + Len2 * Len3 * r;
    V = uav_interp2(SUB2, Dim2, Len2, X2, Dim3, Len3, X3);
    SUB2 = A + Len2 * Len3 * (r + 1);
    W = uav_interp2(SUB2, Dim2, Len2, X2, Dim3, Len3, X3);

    Y = V + (W - V) * DA;
    return (Y);
}

static int uav_find(double A[], double X, int len) {
    int result = 0;
    int i, P_Start, P_End;

    if (A[0] < A[len - 1]) { /*[数组顺序排列]*/
        P_Start = 0;
        P_End = len;

        if (X < A[0])
            result = 0;
        else if (X < A[len - 1]) {
            if (X > A[len / 2])
                P_Start = len / 2;
            else
                P_End = len / 2 + 1;

            for (i = P_Start; i < P_End; i++) {
                if (X < A[i]) {
                    result = i - 1;
                    break;
                }
            }
        } else
            result = len - 2;
    } else { /*[数组逆序排列]*/
        P_Start = len - 1;
        P_End = 0;

        if (X >= A[0])
            result = 0;
        else if (X > A[len - 1]) {
            if (X > A[len / 2])
                P_Start = len / 2 + 1;
            else
                P_End = len / 2;

            for (i = P_Start; i >= P_End; i--) {
                if (X < A[i]) {
                    result = i;
                    break;
                }
            }
        } else
            result = len - 2;
    }
    return (result);
}
