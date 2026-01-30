function [blinkOnset, blinkOffset,params] = create_blink_fixation(blinkFixDur, params)
% Shows a red dot that blinks 3 times within blinkFixDur (ms).
% Returns onset (first flip) and offset (final clear flip).

    blinkFixDur = blinkFixDur / 1000;  % ms -> s

    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;

    % Dot settings
    red = [255 0 0]; 
    green = [0 255 0];
    % Find center
    Screen('TextSize', win, round(double(params.FIX_SIZE_PX)));
  % Timing: 3 blinks => 3 ON pulses. Use equal ON/OFF inside total duration.
    nBlinks = 3;
    nPhases = 2 * nBlinks;                 % ON,OFF,ON,OFF,ON,OFF
    phaseDur = blinkFixDur / nPhases;      % seconds per phase

    % Optional: start with dot ON
    startT = GetSecs;
    t = startT;

    blinkOnset = NaN;

    for p = 1:nPhases
        isOn = mod(p, 2) == 1;  % odd phases ON, even phases OFF
        if p==nPhases
            params.FIX_COLOR = green; 
        else 
            params.FIX_COLOR = red;
        end
        
        if isOn
            Screen('FillRect', win, bg);
            DrawFormattedText(win, '+', 'center','center', params.FIX_COLOR);
            Screen('Flip', win);
        else
            Screen('FillRect', win, bg);
        end
        
        
        flipTime = Screen('Flip', win);

        if isnan(blinkOnset)
            blinkOnset = flipTime;  % first displayed frame timestamp
        end

        % Schedule next phase end precisely (no drift)
        t = t + phaseDur;
        WaitSecs('UntilTime', t);
    end

    % Ensure it ends cleared
    Screen('FillRect', win, bg);
    blinkOffset = Screen('Flip', win);

    fprintf('blinkOnset at %g s\n', blinkOnset);
    fprintf('blinkOffset at %g s\n', blinkOffset);
end
