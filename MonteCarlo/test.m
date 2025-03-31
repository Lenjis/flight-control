global pcl pcd pcm pcQ pcele peng pwind pcweight pcG;

idx = 1;

pcl = 0.9 + rand() * 0.2; % 0.9-1.1
pcd = 0.8 + rand() * 0.4; % 0.8-1.2
pcm = 0.8 + rand() * 0.4;
pcQ = 0.5 + rand() * 1; % 0.5-1.5
pcele = 0.9 + rand() * 0.2;
pwind = -6 + rand() * 9;
pcweight = -3 + rand() * 6; % -3,3
pcG = -0.02 + rand() * 0.04; % -0.02 0.02
sim('uavApproach_Vt_PI');
TBL_X(idx) = ans.simout(length(ans.simout), 4);
TBL_Y(idx) = ans.simout(length(ans.simout), 6);
TBL_VT(idx) = ans.simout(length(ans.simout), 1);
TBL_alpha(idx) = ans.simout(length(ans.simout), 2);
TBL_theta(idx) = ans.simout(length(ans.simout), 11);
% TBL_ele(idx) = wout(length(wout), 1);
% TBL_w(idx) = wout(length(wout), 2);
% TBL_eng(idx) = wout(length(wout), 3);
idx = idx + 1;
