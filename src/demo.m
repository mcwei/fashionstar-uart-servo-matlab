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
% ====== 单圈控制 ======
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

% ====== 释放 ======
delete(servo);