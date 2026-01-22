function [row,params] = load_trial(i,row,params)

    fprintf('Loading Trial %d\n',i);
    
    if row.speedCueTrial(1) == 1 
        [row.speedCueOnset,row.speedCueOffset] = create_speed_cue(row.speed(1),params);
    end
    
    [row.blinkFixOnset,row.blinkFixOffset] = create_blink_fixation(row.blinkFixDur(1),params);
    
    
    if row.feedbackDur(1) > 0
        [row.sampleOnset,row.sampleOffset,params] = create_sample(row.sampleDur(1),row.startCat(1),row.startCatPos(1),row.startId(1),row.targetCat(1),row.targetCatPos(1),row.targetId(1),params);
%         fprintf('StartId %d TargetId %d Distance %d \n startCat %s targetCat %s \n',row.startCatPos(1),row.targetCatPos(1),row.distance(1),params.categories{row.startCat(1)},params.categories{row.targetCat(1)})
%         fprintf('Normal trial');
%         WaitSecs(1);
        movementDur = row.ts(1) + row.bufferDur(1);
        [row.movementOnset, row.movementOffset, row.tp, params] = create_movement(row.speed(1),movementDur,params);
        [row.feedbackOnset,row.feedbackOffset,params] = create_feedback(row.feedbackDur(1),params);

    else
        [row.sampleOnset,row.sampleOffset,params] = create_sample(row.sampleDur(1),row.startCat(1),row.startCatPos(1),row.startId(1),row.targetCat(1),row.targetCatPos(1),row.targetId(1),params);
%         fprintf('StartId %d ProbeId %d ProbeDist %d \n startCat %s probeCat %s \n',row.startCatPos(1),row.probeCatPos(1),row.probeDist(1),params.categories{row.startCat(1)},params.categories{row.probeCat(1)})
%         fprintf('Probe trial\n');
%         WaitSecs(1);
        movementDur = row.probe_ts(1);
        [row.movementOnset, row.movementOffset, row.tp, params] = create_movement(row.speed(1),movementDur,params);
        [row.probeOnset, row.probeOffset, row.probeResp, params]   =  create_probe(row.probeCat(1),row.probeCatPos(1),row.probe_loc(1),row.optionCat(1),params);

    end
        
    [row.itiOnset,row.itiOffset,params] = create_iti(row.itiDur(1),params);

    return 


end