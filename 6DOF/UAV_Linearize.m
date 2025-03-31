clear;
V = 50;
H = 1000;
path = 0;

[xtrim, ytrim, utrim, dxtrim] = UAV_Trim_2(V, H, path); % Get the trim data
[a, b, c, d] = linmod('UAV_Ctrl', xtrim, utrim); % Linearize the model
[along, blong, clong, dlong] = ssselect(a, b, c, d, [1; 4], [1; 2; 6; 8; 11], [1; 2; 6; 8; 11]); %longitudinal subsystem
[alate, blate, clate, dlate] = ssselect(a, b, c, d, [2; 3], [1; 3; 7; 9; 10; 12], [1; 3; 7; 9; 10; 12]); %lateral subsystem

[num, den] = ss2tf(along, blong, clong(4, :), dlong(4, :), 1);  % Transfer function for longitudinal subsystem
printsys(num, den, 's')
