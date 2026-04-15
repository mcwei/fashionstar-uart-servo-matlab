clc; clear;

% ====== 参数配置 ======
port = 'COM8';     % 根据你的实际串口修改
baud = 115200;     % 根据你的实际波特率修改
       % 根据你的实际舵机ID修改

% ====== 初始化 ======
servo = Servo(port, baud);

ids = [0 2 5];   % 三个舵机

% ===== 批量监控 =====
datas = servo.syncReadMonitor(ids);

% ===== 输出 =====
for i = 1:length(datas)



    fprintf('\n=== Servo %d ===\n', datas(i).id);
    fprintf('Angle     : %.1f °\n', datas(i).angle);
    fprintf('Turns     : %d\n', datas(i).turns);
    fprintf('Temp      : %.2f ℃\n', datas(i).temperature);
    fprintf('Voltage   : %.2f V\n', datas(i).voltage/1000);
    fprintf('Current   : %.3f A\n', datas(i).current/1000);
    fprintf('Power     : %.2f W\n', datas(i).power/1000);

end

delete(servo);