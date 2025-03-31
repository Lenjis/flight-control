function [xtrim, ytrim, utrim, dxtrim] = UAV_Trim_2(V, H, path)
    % [xtrim,utrim]=cktrim(V,H,path)
    % Calculate trim data
    %      1   2      3     4   5   6    7  8  9  10   11     12
    % X = [Vt, alpha, beta, PN, PE, alt, P, Q, R, phi, theta, psi]
    %      1   2      3     4   5   6    7  8  9  10   11     12
    % Y = [Vt, alpha, beta, PN, PE, alt, P, Q, R, phi, theta, psi]
    %      1         2        3       4
    % u = [elevator, aileron, rudder, thruttle]

    x0 = [V; deg2rad(4); 0; 0; 0; H; 0; 0; 0; 0; deg2rad(4 + path); 0];
    IX = [3; 6; 7; 8; 9; 10; 12];

    u0 = [0; 0; 0; 100];
    IU = [2; 3; 4];

    y0 = [V; 2; 0; 0; 0; H; 0; 0; 0; 0; 2; 0];
    IY = [3; 6; 7; 8; 9; 10; 12];

    dx0 = zeros(12, 1);
    IDX = [1; 2; 3; 6; 7; 8; 9; 10; 11; 12];
    %IDX = [3; 6; 7; 8; 9; 10; 12];

    % options = optimset('MaxFunEvals', 2e4, 'TolX', 1e-4, 'TolFun', 1e-4);

    [xtrim, utrim, ytrim, dxtrim] = trim('UAV_Ctrl', x0, u0, y0, IX, IU, IY, dx0, IDX);
end