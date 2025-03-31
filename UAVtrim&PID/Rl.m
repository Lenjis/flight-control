[a, b, c, d] = linmod('uavR_R_beta');
[num, den] = ss2tf(a, b, c(1, :), d(1, :), 1);
[numm, denm] = minreal(num, den);
printsys(numm, denm, 's')
rlocus(-numm, denm)
sgrid
