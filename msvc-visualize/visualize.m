filePath = 'C:\Users\rzxha\Documents\Courses\飞行控制\uav-sim\build\Debug\simu.txt';

close all;

% read the data
cout = readtable(filePath, 'Delimiter', '\t', 'ReadVariableNames', true);

figure;
% plot c simulation output
plot(cout.PN, cout.H, 'LineWidth', 2);
hold on;

% plot(cout.t, cout.H_cmd, 'LineWidth', 2);
% hold on;

plot(out.simout.signals.values(:, 4), out.simout.signals.values(:, 6), 'LineWidth', 2)

title("H");
