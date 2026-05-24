function [row,params] = load_trial(row,params)
    params.trial = struct();
    params.trial(params.trialId).speed = row.speed(1);
    params.trial(params.trialId).trialId = params.trialId;
    params.trial(params.trialId).isProbe = row.probe_dur(1) > 0;
    params.trial(params.trialId).visual = row.visual(1);
    params.trial(params.trialId).targetId = row.target_id(1);

    if row.speed_cue_dur(1) > 0 
       [row.speed_cue_onset,row.speed_cue_offset,row.speed_cue_da,params] = create_speed_cue(params);
    end
    
    if params.iseye
        params.trial.edfFile = eye_startRecording(params);
        row.eye_start_time = GetSecs;
        Eyelink('Message', 'run %d block %d trial %d ', params.runId, params.blockId, params.trialId );
    end

    KbName('UnifyKeyNames');
    escKey = KbName('ESCAPE'); 

    fprintf(' Run %d , Trial %d\n',params.runId,params.trialId);
    
    [row.iti_onset,row.iti_offset,row.iti_da,row.eye_stop_time,params] = create_iti(row.iti_dur(1),params);

    [row.blink_fix_onset,row.blink_fix_offset,row.blink_fix_da, params] = create_blink_fixation(params);
 

       
    if ~params.trial.isProbe 
        
        [row.sample_onset,row.sample_offset,row.sample_da,params] = create_sample(row.sample_dur(1),row.start_id(1),row.category_id(1),row.category_target_id(1),row.target_id(1),params);
        [keyIsDown, ~, keyCode] = KbCheck(params.kbdDeviceIndex);

        if keyIsDown && keyCode(escKey)
            sca;
            error('UserAbort:ESC', 'Experiment aborted by user');
        end
        
        movement_dur = row.ts(1) + row.buffer_dur(1);
        [row.movement_onset, row.movement_offset, row.movement_da, row.target_pos, row.tp, params] = create_movement(row.start_id(1),row.target_id(1),params.trial.speed,movement_dur,row.visual(1),params);
        
        if params.ismeg                    
            trigger_meg_send(params.triggers.MOV_END,0.005);
        end

        [row.feedback_onset,row.feedback_offset,row.feedback_da,params] = create_feedback(row.feedback_dur(1),params);

    else
        
        [row.sample_onset,row.sample_offset,row.sample_da,params] = create_sample(row.sample_dur(1),row.start_id(1),row.category_id(1),row.category_target_id(1),row.target_id(1),params);
        [keyIsDown, ~, keyCode] = KbCheck(params.kbdDeviceIndex);

        if keyIsDown && keyCode(escKey)
            sca;
            error('UserAbort:ESC', 'Experiment aborted by user');
        end


        movement_dur = row.probe_ts(1);
        
        [row.movement_onset, row.movement_offset, row.movement_da, row.target_pos, row.tp, params] = create_movement(row.start_id(1),row.target_id(1),params.trial.speed,movement_dur,row.visual(1),params);

        if row.tp(1) < 0
            [row.probe_onset, row.probe_offset, row.probe_resp_key,row.probe_resp_time, row.probe_da, params]   =  create_probe(row.probe_cat(1),row.probe_cat_pos(1),row.probe_loc(1),row.option_cat(1),params);
            if params.ismeg
                trigger_meg_send(params.triggers.PROBE_END,0.005);
            end
            % no feedback for probe trials
        else
            if params.ismeg
                trigger_meg_send(params.triggers.MOV_END,0.005);
            end
            % if early stop show feedbacbk for 1 sec.
            [row.feedback_onset,row.feedback_offset,row.feedback_da,params] = create_feedback(row.feedback_dur(1),params); % pass feedback duration in ms

        end
    end
 
    
   
end
