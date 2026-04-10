classdef Servo < handle

    properties
        sp
        timeout = 0.2;
    end

    properties (Constant)

        HEADER = uint8([hex2dec('12') hex2dec('4C')]);
        RESP_HEADER = uint8([hex2dec('05') hex2dec('1C')]);

        CMD_PING = hex2dec('01');
        CMD_SET_ANGLE = hex2dec('08');
        CMD_READ_ANGLE = hex2dec('0A');
        CMD_STOP = hex2dec('18');
        CMD_DAMPING = hex2dec('09');
        CMD_SET_ORIGIN = hex2dec('17');
        CMD_RESET_TURN = hex2dec('11');
        CMD_READ_MULTI = hex2dec('10');

    end

    methods

        %% 初始化
        function obj = Servo(port, baud)

            instrreset;

            obj.sp = serial(port);

            set(obj.sp, 'BaudRate', baud);
            set(obj.sp, 'Timeout', obj.timeout);

            fopen(obj.sp);

        end


        %% 关闭
        function delete(obj)

            fclose(obj.sp);
            delete(obj.sp);

        end


        %% ========================
        %% checksum
        %% ========================

        function cs = checksum(~, data)

            cs = mod(sum(data),256);

        end


        %% ========================
        %% 发送 packet
        %% ========================

        function send(obj, packet)

            fwrite(obj.sp, packet, 'uint8');

        end


        %% ========================
        %% 接收 packet
        %% ========================

        function data = receive(obj)

            t0 = tic;

            while obj.sp.BytesAvailable == 0

                if toc(t0) > obj.timeout
                    data = [];
                    return;
                end

            end

            data = fread(obj.sp, obj.sp.BytesAvailable);

        end


        %% ========================
        %% 通讯检测
        %% ========================

        function online = ping(obj, id)

            packet = uint8([ ...
                obj.HEADER ...
                obj.CMD_PING ...
                1 ...
                id ...
                0]);

            packet(end) = obj.checksum(packet(1:end-1));

            obj.send(packet);

            resp = obj.receive();

            if isempty(resp)
                online = false;
                return;
            end

            if resp(3) == obj.CMD_PING
                online = true;
            else
                online = false;
            end

        end


        %% ========================
        %% 简易单圈控制
        %% ========================

        function setAngle(obj, id, angle, time, power)

            pos = typecast(int16(angle*10),'uint8');
            t = typecast(uint16(time),'uint8');
            p = typecast(uint16(power),'uint8');

            packet = uint8([ ...
                obj.HEADER ...
                obj.CMD_SET_ANGLE ...
                7 ...
                id ...
                pos ...
                t ...
                p ...
                0]);

            packet(end) = obj.checksum(packet(1:end-1));

            obj.send(packet);

        end


        %% ========================
        %% 读取单圈角度
        %% ========================

        function angle = readAngle(obj, id)

            packet = uint8([ ...
                obj.HEADER ...
                obj.CMD_READ_ANGLE ...
                1 ...
                id ...
                0]);

            packet(end) = obj.checksum(packet(1:end-1));

            obj.send(packet);

            resp = obj.receive();

            if isempty(resp)
                angle = NaN;
                return;
            end

            pos = typecast(uint8(resp(6:7)),'int16');

            angle = double(pos)/10;

        end


        %% ========================
        %% 多圈角度读取
        %% ========================

        function [angle, turns] = readAngleMulti(obj, id)

            packet = uint8([ ...
                obj.HEADER ...
                obj.CMD_READ_MULTI ...
                1 ...
                id ...
                0]);

            packet(end) = obj.checksum(packet(1:end-1));

            obj.send(packet);

            resp = obj.receive();

            if isempty(resp)
                angle = NaN;
                turns = NaN;
                return;
            end

            pos = typecast(uint8(resp(6:9)),'int32');
            turns = typecast(uint8(resp(10:11)),'int16');

            angle = double(pos)/10;

        end


        %% ========================
        %% 停止
        %% ========================

        function stop(obj, id, mode, power)

            p = typecast(uint16(power),'uint8');

            packet = uint8([ ...
                obj.HEADER ...
                obj.CMD_STOP ...
                4 ...
                id ...
                mode ...
                p ...
                0]);

            packet(end) = obj.checksum(packet(1:end-1));

            obj.send(packet);

        end


        %% ========================
        %% 阻尼控制
        %% ========================

        function damping(obj, id, power)

            p = typecast(uint16(power),'uint8');

            packet = uint8([ ...
                obj.HEADER ...
                obj.CMD_DAMPING ...
                3 ...
                id ...
                p ...
                0]);

            packet(end) = obj.checksum(packet(1:end-1));

            obj.send(packet);

        end


        %% ========================
        %% 设置原点
        %% ========================

        function setOrigin(obj, id)

            packet = uint8([ ...
                obj.HEADER ...
                obj.CMD_SET_ORIGIN ...
                2 ...
                id ...
                0 ...
                0]);

            packet(end) = obj.checksum(packet(1:end-1));

            obj.send(packet);

        end


        %% ========================
        %% 重置圈数
        %% ========================

        function resetTurn(obj, id)

            packet = uint8([ ...
                obj.HEADER ...
                obj.CMD_RESET_TURN ...
                1 ...
                id ...
                0]);

            packet(end) = obj.checksum(packet(1:end-1));

            obj.send(packet);

        end


    end

end