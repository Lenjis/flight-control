#include <windows.h>
#include <math.h>
#include <stdio.h>
#include <time.h>
#include "Sim.h"
#include "model.h"
#include <mmsystem.h>
#pragma comment(lib,"winmm.lib")

void		(*aircraft)();
double	T, x[13], u[3], t=0;
int			sim_step,sim_status;

short step_long=0;
double theta_cmd, theta_var, phi_cmd, phi_var;
short flag_Stop=1;

/*飞行器纵向控制*/
void  ctrl_long(void)
{
    static  double   KeTHETA=0.45, KeQ=0.25, Kephi=0.05;
	
    ac_ele = KeTHETA*(ac_theta*Rad2Deg-theta_cmd) + KeQ*ac_Q*Rad2Deg;
	
}
/*飞行器横侧向控制*/
void  ctrl_late (void)
{
    static double    Kaphi = 0.5,  KaP    = 0.1;

    ac_ail = Kaphi*(ac_phi*Rad2Deg-phi_cmd) + KaP*ac_P*Rad2Deg;
}

/*飞行器控制模块*/
void  ctrl_task(void)
{
	switch(step_long){
		case 0:
			theta_cmd=2;
			phi_cmd =0;
			if(t>=10)  step_long++;
			break;
		case 1:
				theta_cmd = 2;  //t*3.14/5- 周期T=10s
				 phi_cmd = 30;
			 if(t>=20) step_long++;
			break;
		case 2:
				theta_cmd = 2;  //t*3.14/5- 周期T=10s
				 phi_cmd = 0;
			 if(t>=30) step_long++;
			break;
		case 3:
				theta_cmd = 2;  //t*3.14/5- 周期T=10s
				 phi_cmd = -30;
			 if(t>=40) step_long++;
			break;
		case 4:
			flag_Stop=0;
			break;
		default:
			break;	
	}
	//	ctrl_cmdSmooth();
	ctrl_long();
	ctrl_late();
}

/*飞行器模型解算模块，无需看懂*/
void simu_run(void)
{
	static double g=9.8;
	static double stheta,ctheta, sphi,cphi, spsi,cpsi;	

	x[0]=ac_Vt;    x[3]=ac_phi;   x[6]=ac_P;  x[9] =ac_PN;
	x[1]=ac_alpha; x[4]=ac_theta; x[7]=ac_Q;  x[10]=ac_PE;
	x[2]=ac_beta;  x[5]=ac_psi;   x[8]=ac_R;  x[11]=ac_H; 

	u[0]=ac_ele;   u[1]=ac_ail;  u[2]=ac_rud;  u[3]=ac_eng; 

	rk4(aircraft, t, x, u, 12, T, x, &t);

	ac_Vt=x[0];      ac_phi=x[3];  ac_P=x[6];   ac_PN=x[9];
	ac_alpha=x[1]; ac_theta=x[4];  ac_Q=x[7];  ac_PE=x[10];
	ac_beta=x[2];    ac_psi=x[5];  ac_R=x[8];   ac_H=x[11];

	ac_track = (ac_psi)*Rad2Deg;
	if (ac_track<   0.0) ac_track = ac_track+360.0;
	if (ac_track>=360.0) ac_track = ac_track-360.0;
	ac_track = ac_track/Rad2Deg;


}
/*飞行器模型解算初始化，无需看懂*/
void simu_init(void)
{
	ac_Vt=35;         ac_alpha=0/Rad2Deg;   ac_beta=0/Rad2Deg;
	ac_phi=0.0/Rad2Deg;  ac_theta=0/Rad2Deg;   ac_psi=0.0/Rad2Deg;
	ac_P =0/Rad2Deg;     ac_Q=0/Rad2Deg; ac_R=0/Rad2Deg;  
	ac_PN=0.0/Rad2Deg;   ac_PE=0.0/Rad2Deg; ac_H=1000; 

	sim_step=5;   //5ms
	sim_status =0;
	T = sim_step / 1000.0f; 	t = 0;
	aircraft= model6dof;

	ac_ele=0.0;     ac_ail=0.0;  ac_rud=0.0;	ac_eng =0.27;
}

void CALLBACK Timerdefine(UINT uDelay, UINT uMsg, DWORD dwUser, DWORD dw1,	DWORD dw2)
{	
	static short cnt=0;
	cnt++; cnt%=100; 

	simu_run();      /*无人机模型解算 解算周期5ms*/

	if(cnt%2==1) ctrl_task();     /*简单的飞行控制*/	
}

void main(void)
{
MMRESULT idtimer; 
FILE    *fp;
static short count=0;


	simu_init();

	idtimer=timeSetEvent(5,5,Timerdefine,0,TIME_PERIODIC);   //5ms中断一次

	fp = fopen("simu.txt","w");  //openfile

	while (flag_Stop){
		Sleep(100);
		count++; count%=10;
		if(count==1){
			printf( "Hello  phi: %lf  theta: %lf  psi: %lf\n", 
				ac_phi*Rad2Deg, 
				ac_theta*Rad2Deg, 
				ac_psi*Rad2Deg
				);
		}

		
		fprintf(fp, "%lf  %lf %lf %lf\n", 
			    t,
				ac_phi*Rad2Deg, 
				ac_theta*Rad2Deg, 
				-ac_psi*Rad2Deg
			);
		
	};

	fclose(fp);
}