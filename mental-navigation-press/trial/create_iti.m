function [itiOnset, itiOffset, params, dataTransferTime, remainingTime] = create_iti(itiDur, params)
% CREATE_ITI
% Shows blank screen for itiDurMs milliseconds, while overlapping data saving.
%
% Outputs:
%   itiOnset           - time of flip
%   itiOffset          - time when ITI ends (actual)
%   dataTransferTime   - seconds spent saving during ITI
%   remainingTime      - seconds waited after saving (can be 0)
    itiDur = itiDur / 1000;  % ms -> s

    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;

    % 1) Start ITI visually
    Screen('FillRect', win, bg);
    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 
    
    itiOnset = Screen('Flip', win);

    % 2) Do the expensive work during ITI
    t0 = GetSecs;
    if isfield(params,'iseye') && params.iseye
        eye_stopRecording(params.runId, params.blockId,params.trialId);
        outfile = sprintf('r%d_b%d_t%d', params.runId, params.blockId,params.trialId);
        outfilePath = fullfile(params.outDir, sprintf('%s.edf',outfile));
        eye_saveEDF(params, outfilePath);
    end

    t1 = GetSecs;

    dataTransferTime = t1 - t0;              % time spent saving
    elapsedSinceOnset = t1 - itiOnset;       % total elapsed in ITI so far

    % 3) Wait only the remaining time
    target = itiOnset + itiDur;
    remainingTime = target - GetSecs;

    if remainingTime > 0
        itiOffset = WaitSecs('UntilTime', target);
    else
        itiOffset = GetSecs;  % already overran ITI
        remainingTime = 0;
    end

    % Optional: log
    % fprintf('ITI dur=%.3f, elapsed=%.3f, save=%.3f, wait=%.3f, overrun=%.3f\n', ...
    %     itiDur, elapsedSinceOnset, dataTransferTime, remainingTime, max(0, elapsedSinceOnset-itiDur));
end
