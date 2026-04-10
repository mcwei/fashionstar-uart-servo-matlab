classdef Servo < handle

    properties
        sp
        timeout = 0.02;
    end

    properties (Constant)

        HEADER = uint8([hex2dec('12') hex2dec('4C')]);
        RESP_HEADER = uint8([hex2dec('05') hex2dec('1C')]);

        CMD = struct( ...
            'PING', hex2dec('01'), ...
            'SET_ANGLE', hex2dec('08'), ...
            'READ_ANGLE', hex2dec('0A'), ...
            'READ_MULTI', hex2dec('10'), ...
            'STOP', hex2dec('18'), ...
            'DAMPING', hex2dec('09'), ...
            'SET_ORIGIN', hex2dec('17'), ...
            'RESET_TURN', hex2dec('11'), ...
            'SET_MULTI', hex2dec('0D') ...
        );

    end

    %% ========================
    %% 初始化
    %% ========================
    methods

        function obj = Servo(port, baud)

            instrreset;

            obj.sp = serial(port);
            set(obj.sp,'BaudRate',baud);
            set(obj.sp,'Timeout',obj.timeout);

            fopen(obj.sp);

        end

        function delete(obj)
            fclose(obj.sp);
            delete(obj.sp);
        end

    end

    %% ========================
    %% 基础函数
    %% ========================

    methods

        function cs = checksum(~, data)
            cs = mod(sum(data),256);
        end


        function packet = buildPacket(obj, cmd, id, payload)

            LEN = 1 + length(payload);

            packet = uint8([ ...
                obj.HEADER ...
                cmd ...
                LEN ...
                id ...
                payload ...
                0]);

            packet(end) = obj.checksum(packet(1:end-1));
        end


        function send(obj, packet)
            fwrite(obj.sp, packet, 'uint8');
        end

        function pkt = readPacket(obj)

            t_start = tic;

    % ====== 预分配 buffer======
            buffer = zeros(256,1,'uint8');   % 固定缓冲区
            buf_len = 0;

            while true

        % ====== 超时判断（优化2：减少toc调用）======
                if toc(t_start) > obj.timeout
                    pkt = [];
                    return;
                end

        % ====== 读取串口数据 ======
                n = obj.sp.BytesAvailable;

                if n > 0

            % 防止溢出
                    if buf_len + n > length(buffer)
                % 简单策略：重置缓冲区
                        buf_len = 0;
                    end

                    data = fread(obj.sp, n, 'uint8');

            % 写入buffer
                    buffer(buf_len+1 : buf_len+n) = data;
                    buf_len = buf_len + n;

                end

        % ====== 最小帧长度判断 ======
                if buf_len < 6
                    continue;
                end

        % ====== 查找帧头 ======
                idx = -1;
                for i = 1 : buf_len-1
                    if buffer(i) == obj.RESP_HEADER(1) && ...
                       buffer(i+1) == obj.RESP_HEADER(2)
                        idx = i;
                        break;
                    end
                end

                if idx < 0
                    continue;
                end

        % ====== 是否足够读长度 ======
                if buf_len < idx + 3
                    continue;
                end

                len = buffer(idx+3);
                total_len = 2 + 1 + 1 + len + 1;

        % ====== 是否完整包 ======
                if buf_len < idx + total_len - 1
                    continue;
                end

                pkt = buffer(idx : idx+total_len-1);

        % ====== checksum校验 ======
                cs = obj.checksum(pkt(1:end-1));

                if cs == pkt(end)
                    return;
                else
            % 校验失败，丢弃这一段
                    buf_len = 0;
                end

            end

        end
    end
    %% ========================
    %% 功能函数
    %% ========================

    methods

        %% PING
        function ok = ping(obj, id)

            packet = obj.buildPacket(obj.CMD.PING, id, []);

            obj.send(packet);

            resp = obj.readPacket();

            ok = ~isempty(resp);

        end


        %% 单圈控制
        function setAngle(obj, id, angle, time, power)

            payload = [ ...
                typecast(int16(angle*10),'uint8') ...
                typecast(uint16(time),'uint8') ...
                typecast(uint16(power),'uint8')];

            packet = obj.buildPacket(obj.CMD.SET_ANGLE, id, payload);

            obj.send(packet);

        end


        %% 单圈读取
        function angle = readAngle(obj, id)

            packet = obj.buildPacket(obj.CMD.READ_ANGLE, id, []);

            obj.send(packet);

            resp = obj.readPacket();

            if isempty(resp)
                angle = NaN;
                return;
            end

            pos = typecast(uint8(resp(6:7)),'int16');

            angle = double(pos)/10;

        end


        %% 多圈读取
        function [angle, turns] = readAngleMulti(obj, id)

            packet = obj.buildPacket(obj.CMD.READ_MULTI, id, []);

            obj.send(packet);

            resp = obj.readPacket();

            if isempty(resp)
                angle = NaN; turns = NaN;
                return;
            end

            pos = typecast(uint8(resp(6:9)),'int32');
            turns = typecast(uint8(resp(10:11)),'int16');

            angle = double(pos)/10;

        end


        %% 多圈控制
        function setAngleMulti(obj, id, angle, time, power)

            payload = [ ...
                typecast(int32(angle*10),'uint8') ...
                typecast(uint32(time),'uint8') ...
                typecast(uint16(power),'uint8')];

            packet = obj.buildPacket(obj.CMD.SET_MULTI, id, payload);

            obj.send(packet);

        end


        %% 停止 mode：  16 停止释放 17停止锁住 18停止进入阻尼
        function stop(obj, id, mode, power)

            payload = [ ...
                uint8(mode) ...
                typecast(uint16(power),'uint8')];

            packet = obj.buildPacket(obj.CMD.STOP, id, payload);

            obj.send(packet);

        end


        %% 阻尼
        function damping(obj, id, power)

            payload = typecast(uint16(power),'uint8');

            packet = obj.buildPacket(obj.CMD.DAMPING, id, payload);

            obj.send(packet);

        end


        %% 设置原点
        function setOrigin(obj, id)

            payload = uint8(0);

            packet = obj.buildPacket(obj.CMD.SET_ORIGIN, id, payload);

            obj.send(packet);

        end


        %% 重置圈数
        function resetTurn(obj, id)

            packet = obj.buildPacket(obj.CMD.RESET_TURN, id, []);

            obj.send(packet);

        end

    end

end