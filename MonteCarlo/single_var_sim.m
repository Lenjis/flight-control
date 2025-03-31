global pcl pcd pcm pcQ pele peng pwind pcweight pcG
pcl = 1; pcd = 1; pcm = 1; pcQ = 1; pele = 1; peng = 1; pwind = 0; pcweight = 0; pcG = 0;
pcl = 1.1;
sim(uavApproach_Vt_PI);
figure(1), plot(simout(:, 4), simout(:, 6)); hold on;
pcl = 1.0;
sim(uavApproach_Vt_PI);
figure(1), plot(simout(:, 4), simout(:, 6)); hold on;
pcl = 0.9;
sim(uavApproach_Vt_PI);
figure(1), plot(simout(:, 4), simout(:, 6)); hold on;
