function trials_df_shuff = create_trial_structure(trials_df,params)
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

    
    if params.session == 1
        trials_df_shuff.visual = zeros(nTrials,1);
        trials_df_shuff.speed  = nan(nTrials,1);   % use NaN so you notice unfilled trials

        blockSize = 6;

        % Each row: [isVisual, speed]
        % (Mental blocks = isVisual 0)
        plan = [
            1 1.2  % visual speed 1
            1 2.0  % visual speed 2
            0 1.2  % mental speed 1
            0 2.0  % mental speed 2
            1 2.0  % visual speed 2
            1 1.2  % visual speed 1
            0 1.2  % mental speed 1
            0 2.0  % mental speed 2
        ];

        nBlocks = size(plan,1);
        totalPlanned = nBlocks * blockSize;
        if totalPlanned > nTrials
            error('Plan uses %d trials but nTrials = %d.', totalPlanned, nTrials);
        end

        % Fill blocks
        for b = 1:nBlocks
            idx = ( (b-1)*blockSize + 1 ) : ( b*blockSize );
            trials_df_shuff.visual(idx) = plan(b,1);
            trials_df_shuff.speed(idx)  = plan(b,2);
        end

        % Rest visual (keep existing speed as-is; set if you want a default)
        trials_df_shuff.visual(totalPlanned+1 : nTrials) = 1;        
    end

    if params.session == 2
        trials_df_shuff.visual = zeros(nTrials,1);
    end
   
end
