clc; clear;

% ====== 参数配置 ======
port = 'COM8';     % 根据你的实际串口修改
baud = 115200;     % 根据你的实际波特率修改
id   = 0;          % 根据你的实际舵机ID修改

% ====== 初始化 ======
servo = Servo(port, baud);


% ====== 数据监控 ======
disp('--- MONITOR---');
data = servo.readMonitor(0);
disp(data);
pause(6);
% ====== 同步指令-多圈角度控制 ======
disp('--- SYNC-SET-ANGLE-MULTI---');
ids = [0 2 3];
angles = [1080 720 -360];   
times = [1000 1000 1000];
powers = [8000 8000 8000];
servo.syncSetAngleMulti(ids, angles, times, powers);
pause(6);
% ====== 同步指令-数据监控 ======
disp('--- SYNC-MONITOR---');
ids = 0:2;
t0 = tic;
datas = servo.syncReadMonitor(ids);
t = toc(t0);
disp(datas);
fprintf('Total time: %.3f ms\n', t*1000);
% ====== 释放 ======
delete(servo);