function [row,params] = load_trial(row,params)
    params.trial = struct();
    params.trial.speed = row.speed(1);
    params.trial.trialId = params.trialId;
    params.trial.isProbe = row.feedbackDur(1) > 0;
    params.trial.visual = row.visual(1);
      
    if row.speedCueTrial(1) == 1 
       [row.speedCueOnset,row.speedCueOffset,row.speedCueDa] = create_speed_cue(row.speed(1),params);
    end
    
    if params.iseye
        params.trial.edfFile = eye_startRecording(params);
        row.eyeStartTime = GetSecs;
        Eyelink('Message', 'run %d block %d trial %d ', params.runId, params.blockId, params.trialId );
    end

   fprintf(' Run %d , Trial %d\n',params.runId,params.trialId);
   
    [row.blinkFixOnset,row.blinkFixOffset,row.blinkFixDa, params] = create_blink_fixation(params);
    
    if row.feedbackDur(1) > 0
         
        [row.sampleOnset,row.sampleOffset,row.sampleDa,params] = create_sample(row.sampleDur(1),row.startId(1),row.targetCat(1),row.targetCatPos(1),row.targetId(1),params);
        movementDur = row.ts(1) + row.bufferDur(1);
        [row.movementOnset, row.movementOffset, row.movementDa, row.targetPos, row.tp, params] = create_movement(row.startId(1),row.targetId(1),row.speed(1),movementDur,row.visual(1),params);
        if params.ismeg                    
            trigger_meg_send(params.triggers.MOV_END,0.005);
        end
        [row.feedbackOnset,row.feedbackOffset,row.feedbackDa,params] = create_feedback(row.feedbackDur(1),params);

    else

        [row.sampleOnset,row.sampleOffset,row.sampleDa,params] = create_sample(row.sampleDur(1),row.startId(1),row.targetCat(1),row.targetCatPos(1),row.targetId(1),params);
        movementDur = row.probe_ts(1);
        [row.movementOnset, row.movementOffset, row.movementDa, row.targetPos, row.tp, params] = create_movement(row.startId(1),row.targetId(1),row.speed(1),movementDur,row.visual(1),params);
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
            [row.feedbackOnset,row.feedbackOffset,row.feedbackDa,params] = create_feedback(1,params);

        end
    end
 
    [row.itiOnset,row.itiOffset,row.itiDa,row.eyeStopTime,params] = create_iti(row.itiDur(1),params);
   
end