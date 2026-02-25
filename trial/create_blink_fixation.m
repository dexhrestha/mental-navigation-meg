function [blinkFixOnset, blinkFixOffset, blinkFixDa, params] = create_blink_fixation(params)

% Shows a red dot that blinks 3 times within blinkFixDur (ms).
% Returns onset (first flip) and offset (final clear flip).
% Also records time of 'z' and '/' keypress (first press only).
    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;
    
    xCenter = params.ptb.xCenter;
    yCenter = params.ptb.yCenter;

    % Dot settings
    red = [255 0 0]; 
    green = [0 255 0];

    % Timing: 3 blinks => 3 ON pulses. Use equal ON/OFF inside total duration.
    nBlinks = 2;
    nPhases = 3 + nBlinks;                % ON,OFF,ON,OFF,ON
%     phaseDur = blinkFixDur / nPhases;      % seconds per phase

    % ---------------------------
    % Response variables
    % ---------------------------

    % Define keys
    KbName('UnifyKeyNames');
    escKey = KbName('ESCAPE'); 
    
    % Optional: start with dot ON
    startT = GetSecs;
    t = startT;

    blinkFixOnset = NaN;
    params.FIX_COLOR = red;
    for p = 1:nPhases
        isOn = mod(p, 2) == 1;  % odd phases ON, even phases OFF

        if isOn
            if p==nPhases
                params.FIX_COLOR = green;
                phaseDur = params.BLINK_FIX_GREEN_DUR;
            else
                params.FIX_COLOR = red;
                phaseDur = params.BLINK_FIX_RED_DUR;
            end

            Screen('FillRect', win, bg);
            
            Screen('TextSize', win, params.FIX_SIZE_PX);
            fixY = params.ptb.yCenter - params.START_Y_PX;
            fixBounds = Screen('TextBounds', win, '+');
            fixRect   = CenterRectOnPointd(fixBounds, xCenter, fixY);
            Screen('DrawText', win, '+', fixRect(1), fixRect(2), params.FIX_COLOR);
            
        else
            phaseDur = params.BLINK_FIX_OFF_DUR;  % can draw from a unif distribution  for the second blink
            Screen('FillRect', win, bg);
        end

        if params.add_bars
            % In each draw frame:
            Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
        end 

        flipTime = Screen('Flip', win);

        if isnan(blinkFixOnset)
            blinkFixOnset = flipTime;  % first displayed frame timestamp
        else
            blinkFixOffset = flipTime;
        end

        % ---------------------------
        % Collect keypresses during this phase
        % ---------------------------
        phaseEnd = t + phaseDur;
        
        KbQueueFlush(params.kbdDeviceIndex); 
        
        % if use wants to abort
        while GetSecs < phaseEnd
            [keyIsDown, pressTime, keyCode] = KbCheck(params.kbdDeviceIndex);

            if keyIsDown
                if keyCode(escKey)
                    sca;
                    error('UserAbort:ESC', 'Experiment aborted by user');
                end
            end
        end

        % Advance absolute schedule (no drift)
        t = phaseEnd;
        blinkFixOffset = WaitSecs('UntilTime', t);
    end
    blinkFixDa = blinkFixOffset - blinkFixOnset;
end
