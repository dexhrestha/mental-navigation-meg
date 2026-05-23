function trials_df = initialize_trials(trials_df)
% Initialize timing/output fields to default value -1

    defaultVal = -1;
    n = height(trials_df);

    %{ 
Add the following columns as empty columns to the trails_df_shuff matrix to
record the output 
    speedCueOnset
    speedCueOffset
    blinkFixationOnset
    blinkFixationOffset
    sampleOnset
    sampleOffset
    movementOnset
    movementOffset
    probeOnset
    probeOffset
    feedbackOnset
    feedbackOffset
    itiOnset
    itiOffset
    targetLMPosition ( in sequence ) - > can be used to define error in terms of visual distance
    Normal trials
    tp
    Probe trials
    probeRespKey 
    probeRespTime
    %}
    
    empty = nan(n,1);

    trials_df.speed_cue_onset    = empty;
    trials_df.speed_cue_offset   = empty;
    trials_df.speed_cue_da       = empty;
    
    trials_df.blink_fix_onset    = empty;
    trials_df.blink_fix_offset   = empty;
    trials_df.blink_fix_da       = empty;
    
    trials_df.sample_onset       = empty;
    trials_df.sample_offset      = empty;
    trials_df.sample_da          = empty;
    
    trials_df.movement_onset     = empty;
    trials_df.movement_offset    = empty;
    trials_df.movement_da        = empty;
    
    trials_df.probe_onset        = empty;
    trials_df.probe_offset       = empty;
    trials_df.probe_da           = empty;
    
    trials_df.feedback_onset     = empty;
    trials_df.feedback_offset    = empty;
    trials_df.feedback_da        = empty;
    
    trials_df.iti_onset          = empty;
    trials_df.iti_offset         = empty;
    trials_df.iti_da             = empty;

    % Normal trials user resp
    trials_df.tp                     = empty;
    % Target position in sequence (can compute error vs achieved position later)
    trials_df.target_pos              = empty;
    %probe trials user resp
    trials_df.probe_resp_key           = empty;
    trials_df.probe_resp_time          = empty;
    
    %eye tracking
    trials_df.eye_start_time = empty;
    trials_df.eye_stop_time = empty;
    
    %meg 
    trials_df.meg_start_time = empty;
    trials_df.meg_stop_time = empty;
end
