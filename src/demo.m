clc; clear;

% ====== 参数配置 ======
port = 'COM8';     % 根据你的实际串口修改
baud = 115200;     % 根据你的实际波特率修改
id   = 0;          % 根据你的实际舵机ID修改

% ====== 初始化 ======
servo = Servo(port, baud);

disp('--- PING ---');
ok = servo.ping(id);

if ok
    disp('Servo online');
else
    disp('Servo NOT detected');
    delete(servo);
    return;
end

pause(0.2);

% ====== 单圈控制 ======
disp('--- SET ANGLE ---');
servo.setAngle(id, -90, 500, 0);   % 90°, 500ms, power=0

pause(1);

% ====== 读取角度 ======
disp('--- READ ANGLE ---');
angle = servo.readAngle(id);

fprintf('Current Angle: %.2f°\n', angle);
% ====== 多圈控制 ======
disp('--- SET ANGLE MULTI TURN---');
% 走 3 圈（1080°）
servo.setAngleMulti(id, 1080, 2000, 0);

pause(2.5);
% ====== 读取角度 ======
[angle, turns] = servo.readAngleMulti(id);

fprintf('Angle: %.2f°\n', angle);
fprintf('Turns: %d\n', turns);
% ====== 停止 ======
disp('--- STOP ---');
servo.stop(id, 16, 2000);
% ====== 异步指令 ======
servo.beginAsync();

servo.setAngle(0, -90, 500, 8000);
servo.setAngle(2, 45, 500, 8000);
servo.setAngle(3, -30, 500, 8000);

servo.endAsync(0);   % 一起执行
pause(1);
% ====== 同步指令-单圈角度控制  ======
ids = [1 0 3];
angles = [90 45 -30];
times = [500 500 500];
powers = [8000 8000 8000];

servo.syncSetAngle(ids, angles, times, powers);
pause(1);
% ====== 数据监控 ======
data = servo.readMonitor(0);

disp(data);
% ====== 同步指令-多圈角度控制 ======
ids = [0 2 3];
angles = [1080 720 -360];   % 多圈
times = [1000 1000 1000];
powers = [8000 8000 8000];

servo.syncSetAngleMulti(ids, angles, times, powers);
% ====== 释放 ======
delete(servo);