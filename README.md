# Fashion Star Uart Servo MATLAB SDK 使用说明

## 1.  SDK简介

本 SDK 用于通过串口（UART）控制Fashion Star UART舵机，当前支持：

- 单圈角度控制
- 多圈角度控制
- 单圈角度读取
- 多圈角度读取
- 阻尼模式
- 停止控制
- 原点设置
- 重置圈数
- 异步指令
- 数据监控
- 同步指令-角度控制
- 同步指令-数据监控



## 2.  环境要求

- MATLAB R2016
- 串口工具箱（内置）
- Windows / Linux / Mac 均可



## 3.  文件结构

```
Servo.m          % 核心SDK类
demo.m     % 示例
```



## 4.  快速开始

### 4.1 初始化

```
servo = Servo('COM3', 115200);
```

------

### 4.2 检测舵机

```
ok = servo.ping(1);
```

返回：

- `true` → 在线
- `false` → 不在线

------

### 4.3 单圈角度控制

```
servo.setAngle(id, angle, time, power);
```

参数说明：

| 参数  | 含义           |
| ----- | -------------- |
| id    | 舵机ID         |
| angle | 角度（°）      |
| time  | 运动时间（ms） |
| power | 功率           |

示例：

```
servo.setAngle(1, 90, 500, 2000);
```

------

### 4.4 单圈角度读取

```
angle = servo.readAngle(id);
```

返回：

- 单位：度（°）
- 失败返回：`NaN`

------

### 4.5 多圈角度控制

```
servo.setAngleMulti(id, angle, time, power);
```

示例：

```
servo.setAngleMulti(1, 1080, 1000, 3000);
```

------

### 4.6 多圈角度读取

```
[angle, turns] = servo.readAngleMulti(id);
```

返回：

| 参数  | 含义     |
| ----- | -------- |
| angle | 当前角度 |
| turns | 圈数     |

------

### 4.7 停止模式

```
servo.stop(id, mode, power);
```

------

### 4.8 阻尼模式

```
servo.damping(id, power);
```

------

### 4.9 原点设置

```
servo.setOrigin(id);
```

------

### 4.10 重置圈数

```
servo.resetTurn(id);
```

------

### 4.11 异步指令

```
servo.beginAsync();
...具体要发送的指令...
servo.endAsync(0); 
```

------

### 4.12 同步指令

```matlab
% ====== 同步指令-单圈角度控制  ======
disp('--- SYNC-SET-ANGLE---');
ids = [1 0 3];
angles = [90 45 -30];
times = [500 500 500];
powers = [8000 8000 8000];
servo.syncSetAngle(ids, angles, times, powers);
pause(3);



% ====== 同步指令-多圈角度控制 ======
disp('--- SYNC-SET-ANGLE-MULTI---');
ids = [0 2 3];
angles = [1080 720 -360];   
times = [1000 1000 1000];
powers = [8000 8000 8000];
servo.syncSetAngleMulti(ids, angles, times, powers);

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
```

------

### 4.13 数据监控

```
servo.readMonitor(id);
```



## 5.  示例程序

可参考`demo.m`程序内容

基础流程：

```
servo = Servo('COM3',115200);

if servo.ping(1)
    servo.setAngle(1, 90, 500, 200);
    pause(1);

    angle = servo.readAngle(1);
    disp(angle);
end

delete(servo);
```



## 6.  注意事项（重要）

### ❗1. LEN定义

```
LEN = 1 + payload长度
```

------

### ❗2. timeout建议

```
timeout = 0.02;   % 推荐
```

------

### ❗3. 串口冲突

初始化前建议：

```
instrreset;
```

------

### ❗4. 数据异常（NaN）

可能原因：

- ID错误
- 接线问题
- 波特率错误
