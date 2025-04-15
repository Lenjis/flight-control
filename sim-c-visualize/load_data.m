filePath = 'simu.txt';

% 读取数据
cout = readtable(filePath, 'Delimiter', '\t', 'ReadVariableNames', true);

% 检查数据
disp('数据已成功加载.');