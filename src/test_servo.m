clc;
clear;
instrreset;
servo = Servo('COM8',115200);

%% ping

if servo.ping(0)

    disp('Servo online');

else

    disp('Servo offline');

end


%% angle control

servo.setAngle(0,90,500,0);

pause(1);


%% read angle

angle = servo.readAngle(0);

disp(angle);


%% loop test

while true

    servo.setAngle(0,0,500,0);
    pause(1);
    angle = servo.readAngle(0);
    disp(angle);
    
    servo.setAngle(0,90,500,0);
    pause(1);
    angle = servo.readAngle(0);
    disp(angle);
end