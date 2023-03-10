classdef Rig < handle
   properties
      server
      isRecording
      shouldTerminate
      latestEncoderReading
      shouldResetPosition
      waterSession
      moveSession
      encoderStart
   end
   methods
        function obj = Rig()
            obj.server = tcpserver(5001);
            obj.isRecording = false;
            obj.shouldTerminate = false;
            obj.shouldResetPosition = false;
            obj.encoderStart = 0;
            obj.latestEncoderReading = 0;
            configureCallback(obj.server, "terminator", @(src,evt)readFcn(obj, src,evt));
        end
        function readFcn(obj,src,~)
            vr.message = readline(src);
            if (vr.message == "start")
                currentPosition = read(obj.daq, 1, "OutputFormat", "Matrix");
                obj.encoderStart = currentPosition;
                obj.isRecording = true;
                obj.shouldResetPosition = true;
                % resetcounters(rig.daq)
                % clear rig.daq;
                % rig.daq = daq("ni");
                % addinput(rig.daq, "Dev2", 'ctr0', 'EdgeCount');
            else
                obj.shouldTerminate = true;
            end
            disp(vr.message);
        end
        function initializeDaq(obj, deviceName)
            daqreset;
            obj.waterSession = daq("ni"); % background operations
            obj.moveSession = daq("ni"); % on-demand operations

            obj.waterSession.Rate = 100;
            addinput(obj.moveSession, deviceName, 'ctr0', 'EdgeCount');
            addoutput(obj.waterSession, deviceName, 'ao0', 'Voltage');
        end
        function reward(obj)
            % for some reason, background signal output does not work
            % preload(obj.waterSession, [ones(1,100)*10 0]');
            % start(obj.waterSession);
            write(obj.waterSession, [10]);
            t = timer;
            t.StartDelay = 1;
            t.TimerFcn = @(~,~)write(obj.waterSession, [0]);
            start(t);
        end
        function delete(obj)
            try
                stop(obj.waterSession);
                stop(obj.moveSession);
            catch
                % do nothing
            end
            obj.server.delete();
        end
   end
end