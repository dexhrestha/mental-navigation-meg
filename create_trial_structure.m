function trials_df_shuff = create_trial_structure(trials_df)
% %CREATE_TRIAL_STRUCTURE Build trial timing columns, create probe schedule, shuffle within groups,
% %and reassign IDs within each run.
% %
% % Assumes trials_df is a MATLAB table with at least:
% %   run, blockId, speed, distance, runTrialId, runBlockId
% % and that truncated_exponential_rvs(mu, a, b, sz) exists.
% 
    nTrials = height(trials_df);

    %% ---------------- Shuffle trials within (run, blockId, speed) ----------------
    % Correct group shuffle: shuffle row indices within each group
    G = findgroups(trials_df.run, trials_df.blockId, trials_df.speed);

    rowIdxCell = splitapply(@(ix){ix(randperm(numel(ix)))}, (1:nTrials)', G);
    rowIdx     = vertcat(rowIdxCell{:});
    
    trials_df_shuff = trials_df(rowIdx, :);

    %% ---------------- Reapply IDs within each run (sorted like your pandas) ----------------
    Grun = findgroups(trials_df_shuff.run);

    tmp = splitapply(@(x){sort(x(:))}, trials_df_shuff.runTrialId, Grun);
    trials_df_shuff.runTrialId = vertcat(tmp{:});

    tmp = splitapply(@(x){sort(x(:))}, trials_df_shuff.runBlockId, Grun);
    trials_df_shuff.runBlockId = vertcat(tmp{:});
    
    
    %% -- set trials with speed cue --
    n = height(trials_df_shuff);
    trials_df_shuff.speedCueTrial = mod((0:n-1)', 6) == 0;
    trials_df_shuff.speedCueTrial = int32(trials_df_shuff.speedCueTrial);

end
