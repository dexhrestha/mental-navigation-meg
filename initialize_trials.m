function trials_df = initialize_trials(trials_df)
% Initialize timing/output fields to default value -1

    defaultVal = -1;
    n = height(trials_df);

    trials_df.speedCueOnset   = repmat(defaultVal, n, 1);
    trials_df.speedCueOffset  = repmat(defaultVal, n, 1);

    trials_df.blinkFixOnset   = repmat(defaultVal, n, 1);
    trials_df.blinkFixOffset  = repmat(defaultVal, n, 1);

    trials_df.sampleOnset     = repmat(defaultVal, n, 1);
    trials_df.sampleOffset    = repmat(defaultVal, n, 1);

    trials_df.movementOnset   = repmat(defaultVal, n, 1);
    trials_df.movementOffset  = repmat(defaultVal, n, 1);

    trials_df.tp              = repmat(defaultVal, n, 1);
end
