function [row,params] = load_trial(row,params)
    params.trial = struct();
    params.trial.speed = row.speed(1);
    params.trial.trialId = params.trialId;
    params.trial.isProbe = row.probe_dur(1) > 0;
    row.visual = 1;
    params.trial.visual = row.visual(1);
    params.trial.targetId = row.target_id(1);
    % if params.trial.speed == 1.2
        % params.trial.speed = 1.6;
    % end

    % speeds = [1.6,1.6,2,1.6,2,2]; 
    % speed_idx = mod(row.runTrialId,6);
    % params.trial.speed = speeds(speed_idx);
    % params.trial.speed = 0.5;
    
    % if row.speedCueTrial(1) == 1 
       % [row.speedCueOnset,row.speedCueOffset,row.speedCueDa,params] = create_speed_cue(params);
    % end
    
    if params.iseye
        params.trial.edfFile = eye_startRecording(params);
        row.eyeStartTime = GetSecs;
        Eyelink('Message', 'run %d block %d trial %d ', params.runId, params.blockId, params.trialId );
    end

    KbName('UnifyKeyNames');
    escKey = KbName('ESCAPE'); 

    fprintf(' Run %d , Trial %d\n',params.runId,params.trialId);
    
    [row.itiOnset,row.itiOffset,row.itiDa,row.eyeStopTime,params] = create_iti(row.iti_dur(1),params);

    [row.blinkFixOnset,row.blinkFixOffset,row.blinkFixDa, params] = create_blink_fixation(params);
 

       
    if ~params.trial.isProbe 
        
        [row.sampleOnset,row.sampleOffset,row.sampleDa,params] = create_sample(row.sample_dur(1),row.start_id(1),row.targetCat(1),row.targetCatPos(1),row.targetId(1),params);
        [keyIsDown, ~, keyCode] = KbCheck(params.kbdDeviceIndex);

        if keyIsDown && keyCode(escKey)
            sca;
            error('UserAbort:ESC', 'Experiment aborted by user');
        end
        
        movementDur = row.ts(1) + row.buffer_dur(1);
        [row.movementOnset, row.movementOffset, row.movementDa, row.targetPos, row.tp, params] = create_movement(row.startId(1),row.targetId(1),params.trial.speed,movementDur,row.visual(1),params);
        
        if params.ismeg                    
            trigger_meg_send(params.triggers.MOV_END,0.005);
        end

        [row.feedbackOnset,row.feedbackOffset,row.feedbackDa,params] = create_feedback(row.feedback_dur(1),params);

    else
        
        [row.sampleOnset,row.sampleOffset,row.sampleDa,params] = create_sample(row.sample_dur(1),row.startId(1),row.targetCat(1),row.targetCatPos(1),row.targetId(1),params);
        [keyIsDown, ~, keyCode] = KbCheck(params.kbdDeviceIndex);

        if keyIsDown && keyCode(escKey)
            sca;
            error('UserAbort:ESC', 'Experiment aborted by user');
        end


        movementDur = row.probe_ts(1);
        
        [row.movementOnset, row.movementOffset, row.movementDa, row.targetPos, row.tp, params] = create_movement(row.startId(1),row.targetId(1),params.trial.speed,movementDur,row.visual(1),params);

        if row.tp(1) < 0
            [row.probeOnset, row.probeOffset, row.probeRespKey,row.probeRespTime, row.probeDa, params]   =  create_probe(row.probeCat(1),row.probeCatPos(1),row.probe_loc(1),row.optionCat(1),params);
            if params.ismeg
                trigger_meg_send(params.triggers.PROBE_END,0.005);
            end
            % no feedback for probe trials
        else
            if params.ismeg
                trigger_meg_send(params.triggers.MOV_END,0.005);
            end
            % if early stop show feedbacbk for 1 sec.
            [row.feedbackOnset,row.feedbackOffset,row.feedbackDa,params] = create_feedback(row.feedback_dur(1),params); % pass feedback duration in ms

        end
    end
 
    
   
end
