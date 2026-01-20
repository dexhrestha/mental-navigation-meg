function params = create_iti(itiDur, params)
% CREATE_ITI
% Shows a blank screen (background color) for itiDur milliseconds.

    if nargin < 1 || isempty(itiDur) || ~isscalar(itiDur) || itiDur < 0
        error('itiDur must be a non-negative scalar (ms).');
    end

    itiDur = itiDur / 1000;  % ms -> s

    win = params.window;
    bg  = params.BG_COLOR;

    % Draw blank screen
    Screen('FillRect', win, bg);
    itiOnset = Screen('Flip', win);

    % Hold for ITI duration (precise)
    WaitSecs('UntilTime', itiOnset + itiDur);
end
