function [blinkFixOnset, blinkFixOffset, blinkFixDa, params] = create_blink_fixation(params)

% Shows a blinking fixation and requires the start key to stay held.
    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;

    xCenter = params.ptb.xCenter;

    red = [255 0 0];
    green = [0 255 0];

    nBlinks = 2;
    nPhases = 3 + nBlinks;

    KbName('UnifyKeyNames');

    startT = GetSecs;
    t = startT;

    blinkFixOnset = NaN;
    blinkFixOffset = NaN;
    params.FIX_COLOR = red;

    for p = 1:nPhases
        isOn = mod(p, 2) == 1;

        if isOn
            if p == nPhases
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
            fixRect = CenterRectOnPointd(fixBounds, xCenter, fixY);
            Screen('DrawText', win, '+', fixRect(1), fixRect(2), params.FIX_COLOR);
        else
            phaseDur = params.BLINK_FIX_OFF_DUR;
            Screen('FillRect', win, bg);
        end

        params.star = drawHyperspaceStarfield(params, 0);
        drawHUD(params);

        if params.add_bars
            Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
        end

        flipTime = Screen('Flip', win);

        if isnan(blinkFixOnset)
            blinkFixOnset = flipTime;
        end

        phaseEnd = t + phaseDur;

        while GetSecs < phaseEnd
            pressed = check_response(params, params.START_KEY, 1);
            params.trial(params.trialId).startPressed = pressed;

            if ~pressed
                blinkFixOffset = GetSecs;
                blinkFixDa = blinkFixOffset - blinkFixOnset;
                return;
            end

            WaitSecs(0.001);
        end

        t = phaseEnd;
        blinkFixOffset = phaseEnd;
    end

    blinkFixDa = blinkFixOffset - blinkFixOnset;
end
