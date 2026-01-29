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

    trials_df.speedCueOnset        = empty;
    trials_df.speedCueOffset       = empty;
    trials_df.blinkFixOnset   = empty;
    trials_df.blinkFixOffset  = empty;
    trials_df.sampleOnset          = empty;
    trials_df.sampleOffset         = empty;
    trials_df.movementOnset        = empty;
    trials_df.movementOffset       = empty;
    trials_df.probeOnset            = empty;
    trials_df.probeOffset           = empty;
    trials_df.feedbackOnset        = empty;
    trials_df.feedbackOffset       = empty;
    trials_df.itiOnset             = empty;
    trials_df.itiOffset            = empty;

    % Target position in sequence (can compute error vs achieved position later)
    trials_df.targetLMPosition     = empty;
    % Normal trials user resp
    trials_df.tp              = empty;
    %probe trials user resp
    trials_df.probeRespKey = empty;
    trials_df.probeRespTime = empty;
    
    %eye tracking
    trials_df.eyeStartTime = empty;
    trials_df.eyeStopTime = empty;
    
    %meg 
    trials_df.megStartTime = empty;
    trials_df.megStopTime = empty;
end
