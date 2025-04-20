filePath = 'simu.txt';

% read the data
cout = readtable(filePath, 'Delimiter', '\t', 'ReadVariableNames', true);

info = stepinfo(cout.theta - 1.1190407073, cout.t);
disp(info);

% plot c simulation output
close all;
plot(cout.t, cout.theta - 1.1190407073, 'LineWidth', 2);
ylim([-1 2]);
xlim([0 5]);

% plot simulink simulation output
hold on
% plot(simout.H.Time, simout.H.Data, 'LineWidth', 2);
