function trials_df_shuff = create_trial_structure(trials_df, params)
%CREATE_TRIAL_STRUCTURE Shuffle trials within (run, blockId, speed),
% reapply IDs within each run, create speedCue schedule, and (session 1)
% overwrite visual+speed for the first planned blocks while keeping original
% speed for the remaining trials (Option B).

    nTrials = height(trials_df);

    %% ---------------- Shuffle trials within (run, blockId, speed) ----------------
    G = findgroups(trials_df.run, trials_df.blockId, trials_df.speed);

    rowIdxCell = splitapply(@(ix){ix(randperm(numel(ix)))}, (1:nTrials)', G);
    rowIdx     = vertcat(rowIdxCell{:});

    trials_df_shuff = trials_df(rowIdx, :);

    %% ---------------- Reapply IDs within each run (sorted like pandas) ----------------
    Grun = findgroups(trials_df_shuff.run);

    tmp = splitapply(@(x){sort(x(:))}, trials_df_shuff.runTrialId, Grun);
    trials_df_shuff.runTrialId = vertcat(tmp{:});

    tmp = splitapply(@(x){sort(x(:))}, trials_df_shuff.runBlockId, Grun);
    trials_df_shuff.runBlockId = vertcat(tmp{:});

    %% ---------------- Set trials with speed cue ----------------
    n = height(trials_df_shuff);
    trials_df_shuff.speedCueTrial = mod((0:n-1)', 6) == 0;
    trials_df_shuff.speedCueTrial = int32(trials_df_shuff.speedCueTrial);

    %% ---------------- Session-specific assignments ----------------
    if params.session == 1
        % Keep original speed so we can restore it after the planned blocks
        origSpeed = trials_df_shuff.speed;

        trials_df_shuff.visual = zeros(n, 1);
        trials_df_shuff.speed  = nan(n, 1);   % NaN to catch anything unfilled

        blockSize = 6;

        % Each row: [isVisual, speed]
        % (Mental blocks = isVisual 0)
        % given starting speed
        speed = origSpeed(1);   % example
        
        % define the two speeds
        allSpeeds =  unique(origSpeed);
        
        % determine the alternate speed
        altSpeed = allSpeeds(allSpeeds ~= speed);
                
        % build alternating speed sequence
        speedSeq = [speed altSpeed speed altSpeed];
        
        % visual = 1, mental = 0
        typeSeq = [1 1 0 0];
        
        % repeat twice (like your original plan)
        typeSeq  = repmat(typeSeq, 1, 2);
        speedSeq = repmat(speedSeq, 1, 2);
        
        % combine
        plan = [typeSeq(:) speedSeq(:)];


        nBlocks = size(plan, 1);
        totalPlanned = nBlocks * blockSize;

        if totalPlanned > n
            error('Plan uses %d trials but nTrials = %d.', totalPlanned, n);
        end

        % Fill planned blocks
        for b = 1:nBlocks
            idx = ((b-1)*blockSize + 1) : (b*blockSize);
            trials_df_shuff.visual(idx) = plan(b, 1);
            trials_df_shuff.speed(idx)  = plan(b, 2);
        end

        % For remaining trials after the plan:
        % - set visual = 1 (as you had)
        % - restore original speed from the shuffled table (Option B)
        if totalPlanned < n
            restIdx = (totalPlanned + 1) : n;
            trials_df_shuff.visual(restIdx) = 1;
            trials_df_shuff.speed(restIdx)  = origSpeed(restIdx);
        end

        % Safety check: no NaNs should remain
        if any(isnan(trials_df_shuff.speed))
            bad = find(isnan(trials_df_shuff.speed));
            error('Speed still NaN at rows: %s', mat2str(bad(1:min(end,20))'));
        end
    end

    if params.session == 2
        trials_df_shuff.visual = zeros(n, 1);
        % (leave speed as-is from input/shuffle for session 2)
    end

end
