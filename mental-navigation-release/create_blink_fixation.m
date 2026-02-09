function [blinkOnset, blinkOffset, params] = create_blink_fixation(blinkFixDur, params)

% Shows a red dot that blinks 3 times within blinkFixDur (ms).
% Returns onset (first flip) and offset (final clear flip).
% Also records time of 'z' and '/' keypress (first press only).

    blinkFixDur = blinkFixDur / 1000;  % ms -> s

    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;

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
    zPressTime     = -1;
    slashPressTime = -1;
    params.trial.buttonPressed  = false;

    % Define keys
    KbName('UnifyKeyNames');
    zKey     = KbName('z');
    slashKey = KbName('/?');   % Psychtoolbox usually maps '/' to '/?'
    escKey = KbName('ESCAPE');
    
    % Optional: start with dot ON
    startT = GetSecs;
    t = startT;

    blinkOnset = NaN;
    params.FIX_COLOR = red;
    for p = 1:nPhases
        isOn = mod(p, 2) == 1;  % odd phases ON, even phases OFF

        if isOn

            if p==nPhases
                params.FIX_COLOR = green;
                phaseDur = 1;
            else
                params.FIX_COLOR = red;
                phaseDur = .8;
            end

            Screen('FillRect', win, bg);
            Screen('TextSize', win, round(double(params.FIX_SIZE_PX)));
            DrawFormattedText(win, '+', 'center',params.ptb.yCenter  - params.START_Y_PX, params.FIX_COLOR);
            
        else
            phaseDur = .05;  % can draw from a unif distribution  for the second blink
            Screen('FillRect', win, bg);
        end

        flipTime = Screen('Flip', win);
        if isnan(blinkOnset)
            blinkOnset = flipTime;  % first displayed frame timestamp
        end  

        % ---------------------------
        % Collect keypresses during this phase
        % ---------------------------
        phaseEnd = t + phaseDur;
        
        KbQueueFlush(params.kbdDeviceIndex); 
        
        while GetSecs < phaseEnd
            [keyIsDown, pressTime, keyCode] = KbCheck(params.kbdDeviceIndex);

            if keyIsDown
                if keyCode(escKey)
                    sca;
                    error('UserAbort:ESC', 'Experiment aborted by user');
                end
                if zPressTime < 0 && keyCode(zKey)
                    zPressTime = pressTime;
                end
                if slashPressTime < 0 && keyCode(slashKey)
                    slashPressTime = pressTime;
                end

                % stop checking if both have been recorded
                if zPressTime > 0 && slashPressTime > 0
                    break;
                end
            end
        end

        % Advance absolute schedule (no drift)
        t = phaseEnd;
        WaitSecs('UntilTime', t);
    end
    

    if p==nPhases
        blinkOffset = GetSecs();
    end
    % Ensure it ends cleared
    %Screen('FillRect', win, bg);
    %blinkOffset = Screen('Flip', win);

    % ---------------------------
    % Combine into final boolean
    % ---------------------------
    if zPressTime > 0 && slashPressTime > 0
        buttonPressed = true;
    else
        buttonPressed = false;
    end
    
    params.trial.zPressTime = zPressTime;
    params.trial.slashPressTime = slashPressTime;
    params.trial.buttonPressed = buttonPressed;
    
    if ~params.trial.buttonPressed
        disp('Blink fix: No button press . show iti and try again ');
    end  

end
