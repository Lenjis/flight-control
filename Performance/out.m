close all;
clear;
set(groot, 'DefaultLineLineWidth', 1.5);

a = -4:0.01:14;
W = 17;
g = 9.8;
S = 1.3536;
Cl = UAV_Cl(a);
Cd0 = UAV_Cd0(a);
K = Cl ./ Cd0;

IDX_alpha = [-4; -2; 0; 2; 4; 8; 12; 16; 20];
TBL_CL0 = [-0.219; -0.04; 0.139; 0.299; 0.455; 0.766; 1.083; 1.409; 1.743];
TBL_CD0 = [0.026; 0.024; 0.024; 0.028; 0.036; 0.061; 0.102; 0.141; 0.173];

figure(1);
plot(a, Cl);
title("升力系数");
xlabel("AoA/deg");
ylabel("C_L");
grid on;
saveas(gcf, 'Cl.jpg');

figure(2);
plot(a, Cd0);
title("阻力系数");
xlabel("AoA/deg");
ylabel("C_D");
grid on;
saveas(gcf, 'Cd.jpg');

figure(3);
plot(a, K);
title("升阻比");
xlabel("AoA/deg");
ylabel("C_L/C_D");
grid on;
saveas(gcf, 'K.jpg');

figure(4);
H = 0:1000:6000;
V = 1:0.1:100;
AR = 7.9756/1.5283;
T_req = zeros(length(H), length(V));
for h = H
    [rho, ~] = UAV_density(h, V);
    Cl_req = (W * g) ./ (0.5 * rho * (V.^2) * S);
    a_req = UAV_Cl_rev(Cl_req);
    Cd0_req = UAV_Cd0(a_req);
    Cdi_req = Cl_req.^2 / (pi * AR);
    T_req(h / 1000 + 1, :) = 0.5 * rho .* (V.^2) * S .* (Cd0_req + Cdi_req);
    plot(V, T_req(h / 1000 + 1, :));
    hold on;
end
legend('H=0m', 'H=1000m', 'H=2000m', 'H=3000m', 'H=4000m', 'H=5000m', 'H=6000m', 'Location', 'northwest');
title("平飞需用推力");
xlabel("v/(m/s)");
ylabel("T_R/N");
ylim([0, 2000]);
grid on;
saveas(gcf, 'Tr.jpg');

figure(5);
H = 1:1:6000;
Vmin = zeros(1, length(H));
[~, IDX] = max(K); %最大升阻比迎角
for h = H
    [rho(h), ~] = UAV_density(h, 0);
    Cl_max = UAV_Cl(a(IDX)); %最大升力系数
    Vmin = sqrt((2 * W * g) ./ (rho .* S .* Cl_max));
end
plot(H, Vmin);
hold on;
title("最小速度");
xlabel("H/m");
ylabel("Vmin/(m/s)");
grid on;
saveas(gcf, 'Vmin.jpg');

figure(6);
H = 1000;
T = W * g * 0.25;
[rho, ~] = UAV_density(H, 0);
am = min(abs(K - 4));
Vmax = sqrt((2 * W * g) ./ (rho .* S .* UAV_Cl(am)));
disp("am=");
disp(am);
disp("Vmax=");
disp(Vmax);

legend('H=0m', 'H=1000m', 'H=2000m', 'H=3000m', 'H=4000m', 'H=5000m', 'H=6000m', 'Location', 'northwest');
title("最大速度");
xlabel("V/(m/s)")
ylabel("T/N");
ylim([0, 2000]);
grid on;
saveas(gcf, 'Vmax1.jpg');

figure(7);
H = 0:1000:6000;
plot(H, Vmax);
title("最大速度");
xlabel("H/m");
ylabel("V/(m/s)");
grid on;
saveas(gcf, 'Vmax2.jpg');

figure(8);
Hmax = 6000;
for h = H
    [~, mach_min] = UAV_density(h, Vmin);
    [~, mach_max] = UAV_density(h, Vmax);
end
plot(mach_min, 1:1:6000);
hold on;
plot(mach_max, H);
hold on;
plot([mach_min(Hmax), mach_max(7)], [Hmax, Hmax]);
plot([mach_min(1), mach_max(1)], [1, 1]);
hold on;
title("飞行包线");
ylabel("H/m")
xlabel("Ma");
grid on;
saveas(gcf, 'Env.jpg');

figure(9);
H = 1:1:6000;
for h = H
    [rho(h), ~] = UAV_density(h, 1);
end
V_takeoff = sqrt((2 * W * g) ./ (rho .* S .* UAV_Cl(14)));
plot(H(1:4000), V_takeoff(1:4000));
title("最小起飞速度");
xlabel("H/m")
ylabel("Vtakeoff/(m/s)");
grid on;
saveas(gcf, 'Vtakeoff.jpg');

figure(10);
[Kmax, idx] = max(K);
disp("Alpha@MaxGlideRatio=")
disp(a(idx))
disp("GlideRatio=")
disp(Kmax)
plot(H, H * Kmax / 1000);
title("最大滑翔距离");
xlabel("H/m")
ylabel("R/km");
grid on;
saveas(gcf, 'Range.jpg');

[~, IDX] = max(K); %最大升阻比迎角
[rho, ~] = UAV_density(1000, 0);
t = 1:100;
Cle = UAV_Cl(a(IDX));
Cde = UAV_Cd0(a(IDX));
Ve = sqrt((2 * W * g) ./ (rho * S * Cle));
Te = 0.5 * rho * Ve^2 * S * (Cde + Cle^2 / (pi * AR));
Cme = interp1(IDX_alpha, TBL_Cm, a(IDX), "spline");
Mzele = interp1(IDX_alpha, TBL_Mz_ele, a(IDX), "linear");
ele = Cme / Mzele;
[~, throttle] = min(abs(UAV_thrust2(2, Ve, t) - Te / 9.8));
disp("Alpha@MaxK=");
disp(a(IDX));
disp("V=");
disp(Ve);
disp("Throttle=");
disp(throttle);
disp("Elevator=");
disp(ele);

close all

function [CL0, CL_ele] = UAV_Cl(alpha)
    IDX_alpha = [-4; -2; 0; 2; 4; 8; 12; 16; 20];
    TBL_CL0 = [-0.219; -0.04; 0.139; 0.299; 0.455; 0.766; 1.083; 1.409; 1.743];
    CL0 = interp1d(TBL_CL0, IDX_alpha, alpha);
    %CL0 = interp1(IDX_alpha, TBL_CL0, alpha, "spline");
    CL_ele = 0.00636;
end

function [CD0] = UAV_Cd0(alpha)
    IDX_alpha = [-4; -2; 0; 2; 4; 8; 12; 16; 20];
    TBL_CD0 = [0.026; 0.024; 0.024; 0.028; 0.036; 0.061; 0.102; 0.141; 0.173];
    CD0 = interp1d(TBL_CD0, IDX_alpha, alpha);
    %CD0 = interp1(IDX_alpha, TBL_CD0, alpha, "spline");
end

function [rho, mach] = UAV_density(h, v)
    if h < 11000
        temp = 1 - 0.0225569 * h / 1000;
        rho = 0.12492 * 9.8 * exp(4.255277 * log(temp));
        mach = v / sqrt(temp) / 340.375;
    else
        temp = 11 - h / 1000;
        rho = 0.03718 * 9.8 * exp(temp / 6.318);
        mach = v / 295.188;
    end
end

function a = UAV_Cl_rev(Cl)
    IDX_alpha = [-4; -2; 0; 2; 4; 8; 12; 16; 20];
    TBL_CL0 = [-0.219; -0.04; 0.139; 0.299; 0.455; 0.766; 1.083; 1.409; 1.743];
    %a = interp1d(IDX_alpha, TBL_CL0, Cl);
    a = interp1(TBL_CL0, IDX_alpha, Cl, "spline");
end

function y = interp1d(A, idx, xi) %#ok<DEFNU>
    if xi < idx(1)
        r = 1;
    elseif xi < idx(end)
        r = max(find(idx <= xi));
    else
        r = length(idx) - 1; %从零开始
    end
    DA = (xi - idx(r)) / (idx(r + 1) - idx(r));
    y = A(r) + (A(r + 1) - A(r)) * DA;
end

function T = UAV_thrust(h, V)
    IDX_Vt = [30, 45, 60];
    TBL_thrust(:, :, 1) = [
                           34.1 25.8 16.3
                           40.9 27.9 23.4
                           63.7 46.8 37.0
                           78.4 61.5 49.3
                           90.8 78.7 62.2
                           100.9 89.6 71.0
                           107.3 97.0 78.4
                           111.6 101.6 83.5
                           114.4 103.4 85.4
                           121.1 111.0 92.8];

    TBL_thrust(:, :, 2) = [
                           32.4 21.5 15.9
                           40.3 29.5 24.5
                           59.9 45.7 36.5
                           73.2 60.0 47.7
                           86.9 76.1 60.9
                           96.3 83.9 67.6
                           102.9 93.8 77.8
                           106.3 98.2 84.2
                           107.8 99.1 84.9
                           113.6 106.1 89.5];

    TBL_thrust(:, :, 3) = [
                           31.6 21 15.5
                           41.7 28.8 24.6
                           58.5 44.6 35.7
                           70.4 58.6 46.6
                           83.5 73.4 59.5
                           89.4 80.8 66
                           97 91.6 77
                           100.1 94.6 81.2
                           103.4 95.4 81.8
                           108.9 103.6 86.2];

    TBL_thrust(:, :, 4) = [
                           30 20.5 15.1
                           40.7 29.3 24.3
                           56.3 43.5 35.3
                           66.6 57.2 45.5
                           77.5 69.7 56.5
                           85.7 78.9 65.3
                           92.9 87 74.2
                           94 91 78.2
                           97.1 93.1 78.7
                           102.2 99.7 82.9];

    TBL_thrust(:, :, 5) = [
                           29.4 20 14.8
                           41 30.2 24.4
                           53.5 42.6 34.5
                           64.2 56 44.5
                           74.5 68.2 55.3
                           80.8 76.1 64.7
                           87.6 85.1 71.4
                           90.2 87.8 75.2
                           93.2 89.9 75.6
                           100 95.8 79.6];

    TBL_thrust(:, :, 6) = [
                           29.6 20.2 14.5
                           40.1 29.9 24.2
                           50.8 41.6 33.8
                           60.7 54.1 42.9
                           71.6 65.9 55.5
                           77.6 73.4 61.6
                           84 82.1 68.6
                           86.5 84.7 72.2
                           89.4 86.7 72.5
                           95.8 91.9 76.3];

    TBL_thrust(:, :, 7) = [
                           29.2 19.9 14.3
                           39.6 29.5 23.9
                           50.1 41.1 33.3
                           59.9 53.3 42.4
                           70.6 65 54.8
                           76.6 72.4 58.5
                           82.9 79.1 65.8
                           85.4 81.6 69.2
                           85.6 83.5 69.4
                           91.6 88 73];
    T = interp1(IDX_Vt, TBL_thrust(10, :, h), V, "spline");
end

function T = UAV_thrust2(h, V, t)
    IDX_Vt = [30, 45, 60];
    IDX_t = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
    [X, Y] = meshgrid(IDX_Vt, IDX_t);
    TBL_thrust(:, :, 1) = [
                           34.1 25.8 16.3
                           40.9 27.9 23.4
                           63.7 46.8 37.0
                           78.4 61.5 49.3
                           90.8 78.7 62.2
                           100.9 89.6 71.0
                           107.3 97.0 78.4
                           111.6 101.6 83.5
                           114.4 103.4 85.4
                           121.1 111.0 92.8];

    TBL_thrust(:, :, 2) = [
                           32.4 21.5 15.9
                           40.3 29.5 24.5
                           59.9 45.7 36.5
                           73.2 60.0 47.7
                           86.9 76.1 60.9
                           96.3 83.9 67.6
                           102.9 93.8 77.8
                           106.3 98.2 84.2
                           107.8 99.1 84.9
                           113.6 106.1 89.5];

    TBL_thrust(:, :, 3) = [
                           31.6 21 15.5
                           41.7 28.8 24.6
                           58.5 44.6 35.7
                           70.4 58.6 46.6
                           83.5 73.4 59.5
                           89.4 80.8 66
                           97 91.6 77
                           100.1 94.6 81.2
                           103.4 95.4 81.8
                           108.9 103.6 86.2];

    TBL_thrust(:, :, 4) = [
                           30 20.5 15.1
                           40.7 29.3 24.3
                           56.3 43.5 35.3
                           66.6 57.2 45.5
                           77.5 69.7 56.5
                           85.7 78.9 65.3
                           92.9 87 74.2
                           94 91 78.2
                           97.1 93.1 78.7
                           102.2 99.7 82.9];

    TBL_thrust(:, :, 5) = [
                           29.4 20 14.8
                           41 30.2 24.4
                           53.5 42.6 34.5
                           64.2 56 44.5
                           74.5 68.2 55.3
                           80.8 76.1 64.7
                           87.6 85.1 71.4
                           90.2 87.8 75.2
                           93.2 89.9 75.6
                           100 95.8 79.6];

    TBL_thrust(:, :, 6) = [
                           29.6 20.2 14.5
                           40.1 29.9 24.2
                           50.8 41.6 33.8
                           60.7 54.1 42.9
                           71.6 65.9 55.5
                           77.6 73.4 61.6
                           84 82.1 68.6
                           86.5 84.7 72.2
                           89.4 86.7 72.5
                           95.8 91.9 76.3];

    TBL_thrust(:, :, 7) = [
                           29.2 19.9 14.3
                           39.6 29.5 23.9
                           50.1 41.1 33.3
                           59.9 53.3 42.4
                           70.6 65 54.8
                           76.6 72.4 58.5
                           82.9 79.1 65.8
                           85.4 81.6 69.2
                           85.6 83.5 69.4
                           91.6 88 73];
    T = interp2(X, Y, TBL_thrust(:, :, h), V, t, "spline");
end
