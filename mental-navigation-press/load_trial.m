function [row,params] = load_trial(row,params)
   % if row.speedCueTrial(1) == 1 
   %     [row.speedCueOnset,row.speedCueOffset] = create_speed_cue(row.speed(1),params);
   % end

   params.trial = struct();
    
   if params.iseye
        Eyelink('Message', 'run %d block %d trial %d ', params.runId, params.blockId, params.trialId );
   end
   
    params.trial.speed = row.speed(1);
    params.trial.trialId = params.trialId;
    params.trial.isProbe = row.feedbackDur(1) > 0;

   fprintf(' Run %d , Trial %d\n',params.runId,params.trialId);
   
    [row.blinkFixOnset,row.blinkFixOffset, params] = create_blink_fixation(params);
    
    if row.feedbackDur(1) > 0
        [row.sampleOnset,row.sampleOffset,params] = create_sample(row.sampleDur(1),row.startId(1),row.targetCat(1),row.targetCatPos(1),row.targetId(1),params);
        movementDur = row.ts(1) + row.bufferDur(1);
        [row.movementOnset, row.movementOffset, row.targetPos, row.tp, params] = create_movement(row.startId(1),row.targetId(1),row.speed(1),movementDur,row.visual(1),params);
        if params.ismeg                    
            trigger_meg_send(params.triggers.MOV_END,0.005);
        end
        [row.feedbackOnset,row.feedbackOffset,params] = create_feedback(row.feedbackDur(1),params);

    else

        [row.sampleOnset,row.sampleOffset,params] = create_sample(row.sampleDur(1),row.startId(1),row.targetCat(1),row.targetCatPos(1),row.targetId(1),params);
        movementDur = row.probe_ts(1);
        [row.movementOnset, row.movementOffset, row.targetPos, row.tp, params] = create_movement(row.startId(1),row.targetId(1),row.speed(1),movementDur,row.visual(1),params);
        if row.tp(1) < 0
            [row.probeOnset, row.probeOffset, row.probeRespKey,row.probeRespTime, params]   =  create_probe(row.probeCat(1),row.probeCatPos(1),row.probe_loc(1),row.optionCat(1),params);
            if params.ismeg
                trigger_meg_send(params.triggers.PROBE_END,0.005);
            end
            % no feedback for probe trials
        else
            if params.ismeg
                trigger_meg_send(params.triggers.MOV_END,0.005);
            end
            % if early stop show feedback for 1 sec.
            [row.feedbackOnset,row.feedbackOffset,params] = create_feedback(1,params);

        end
    end
 
    [row.itiOnset,row.itiOffset,params] = create_iti(row.itiDur(1),params);
   
end