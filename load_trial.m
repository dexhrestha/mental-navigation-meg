function [row,params] = load_trial(i,row,params)

    fprintf('Loading Trial %d\n',i);
    
    [row.speedCueOnset,row.speedCueOffset] = create_speed_cue(row.speed(1),row.speedCueDur(1),params);
    [row.blinkFixOnset,row.blinkFixOffset] = create_blink_fixation(row.blinkFixDur(1),params);
    [row.sampleOnset,row.sampleOffset,params] = create_sample(row.sampleDur(1),row.startCat(1),row.startId(1),row.targetCat(1),row.targetId(1),params);
    % row. ts should be updated from create_trial_structure
    [row.movementOnset, row.movementOffset, row.tp, params] = create_movement(row.ts(1)+row.bufferDur(1),params);
    
     if row.feedbackDur(1) > 0
        [row.feedbackOnset,row.feedbackOffset,params] = create_feedback(row.feedbackDur(1),params);
     else
        [row.probeOnset, row.probeOffset, row.probeResp, params]   =  create_probe(row.probeDur(1),params);
     end
     
    [row.itiOnset,row.itiOffset,params] = create_iti(row.itiDur(1),params);

    return 


end