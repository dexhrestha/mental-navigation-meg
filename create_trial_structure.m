function trials_df_shuff = create_trial_structure(trials_df)
%CREATE_TRIAL_STRUCTURE Build trial timing columns, create probe schedule, shuffle within groups,
%and reassign IDs within each run.
%
% Assumes trials_df is a MATLAB table with at least:
%   run, blockId, speed, distance, runTrialId, runBlockId
% and that truncated_exponential_rvs(mu, a, b, sz) exists.

    nTrials = height(trials_df);

    %% ---------------- Durations (ms unless noted) ----------------
    trials_df.speedCueDur = repmat(250, nTrials, 1);
    trials_df.blinkFixDur = 1000 + rand(nTrials,1).*500;
    trials_df.sampleDur   = repmat(500, nTrials, 1);
    trials_df.feedbackDur = repmat(500, nTrials, 1);
    trials_df.itiDur      = rand(nTrials,1).*500;

    %% ---------------- Probe schedule (0/1 then converted to ms) ----------------
    slow_speed_blocked_probe = repmat([zeros(1,5) 1], 1, 3); % 18 long
    fast_speed_blocked_probe = repmat([zeros(1,5) 1], 1, 3); % 18 long
    all_probes = [fast_speed_blocked_probe slow_speed_blocked_probe]; % 36 long

    runs = unique(trials_df.run, 'stable');
    nRuns = numel(runs);

    % Ensure pattern matches per-run trial count
    nPerRun = sum(trials_df.run == runs(1));
    if any(arrayfun(@(r) sum(trials_df.run == r), runs) ~= nPerRun)
        error('Runs have different numbers of trials. probeDur pattern assignment needs adapting.');
    end
    if nPerRun ~= numel(all_probes)
        error('Per-run trials (%d) must equal probe pattern length (%d).', nPerRun, numel(all_probes));
    end

    trials_df.probeDur = repmat(all_probes(:), nRuns, 1);

    % Shuffle probeDur within each run
    for i = 1:nRuns
        idxRun = trials_df.run == runs(i);
        v = trials_df.probeDur(idxRun);
        trials_df.probeDur(idxRun) = v(randperm(numel(v)));
    end

    % If probeDur==1, set feedbackDur to 0 (probe trial means no feedback)
    trials_df.feedbackDur = (1 - trials_df.probeDur) .* trials_df.feedbackDur;

    %% ---------------- Buffer ----------------
    trials_df.bufferDur = round(1 ./ trials_df.speed, 2);

    buf = trials_df.bufferDur;
    out = zeros(nTrials,1);
    for i = 1:nTrials
        out(i) = truncated_exponential_rvs(1, buf(i)*2, buf(i)*3, [1 1]);
    end
    trials_df.bufferDur = out;

    %% ---------------- Timing ----------------
    trials_df.ts = round(trials_df.distance .* (1 ./ trials_df.speed), 6) .* 1000;

    % Convert probe/buffer to ms
    trials_df.probeDur  = trials_df.probeDur  .* 1000;
    trials_df.bufferDur = trials_df.bufferDur .* 1000;

    % Total duration: sum all *Dur columns + ts
    durNames = trials_df.Properties.VariableNames;
    durVars  = durNames(endsWith(string(durNames), 'Dur'));
    trials_df.trialDur = sum(trials_df{:, durVars}, 2) + trials_df.ts;

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

end
