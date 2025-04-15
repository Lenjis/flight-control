load_data;
close all;
plot(cout.t, cout.H, 'LineWidth', 2);

hold on
plot(simout.H.Time, simout.H.Data, 'LineWidth', 2);
