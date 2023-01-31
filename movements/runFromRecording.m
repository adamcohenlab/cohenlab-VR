function [movement, movementType, encoderReading] = runFromRecording(vr)
    %forward = vr.daq.inputSingleScan;
    encoderReading = 0;
    if vr.iterations > size(vr.recordedPositions,1)
        movement = vr.movement;
        movementType = 'p';
        vr.rig.shouldTerminate = true;
    else
        movement = vr.recordedPositions(vr.iterations,:);
        % disp(movement)
        % % delete from beginning of array
        % vr.recordedPositions(1,:) = [];
        movementType = 'p';
    end
end