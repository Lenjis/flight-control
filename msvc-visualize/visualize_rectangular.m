filePath = 'simu.txt';

close all;

% read the data
cout = readtable(filePath, 'Delimiter', '\t', 'ReadVariableNames', true);

figure;
% plot c simulation output
subplot(1, 2, 1);
plot(cout.t, cout.H, 'LineWidth', 2);
ylim([495 505]);
title("Altitude");

subplot(1, 2, 2);
plot(cout.PE, cout.PN, 'LineWidth', 2);
title("Path");

% plot simulink simulation output
hold on
% plot(simout.H.Time, simout.H.Data, 'LineWidth', 2);

figure;
% plot 3D trajectory
plot3(cout.PE, cout.PN, cout.H, 'b-', 'LineWidth', 2);
grid on;
zlim([0 600]);
xlabel('X Position (m)');
ylabel('Y Position (m)');
zlabel('Altitude (m)');
title('飞行器三维轨迹');
