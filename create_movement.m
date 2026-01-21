function [movementOnset, movementOffset, userInput, params] = create_movement(movementDur, params, vbl0)
% True carousel: smooth motion + rotate IDs when passing one slot spacing.
% movementDur in ms. vbl0 is timestamp from previous Screen('Flip').

    if nargin < 2
        error('Need movementDur and params.');
    end
    if nargin < 3 || isempty(vbl0)
        % Fallback, but this can cause blink if no frame was drawn:
        vbl0 = Screen('Flip', params.window, [], 1);
    end

    if isempty(movementDur) || ~isscalar(movementDur) || movementDur < 0
        error('movementDur must be a non-negative scalar (ms).');
    end

    movementDur = movementDur / 1000;  % ms -> s
    win = params.window;
    bg  = params.BG_COLOR;
    red = [255 0 0];

    userInput = -1;
 
    dotSizePx    = 12;

    [xCenter, yCenter] = RectCenter(Screen('Rect', win));

    n = numel(params.trial.imgArrPos);

    % --- motion control: EXACTLY 100 px in 1 second ---
    speedPxPerSec = 100;
    ifi = Screen('GetFlipInterval', win);
    dxPerFrame = speedPxPerSec * ifi;

    % Base slot positions and spacing
    basePos = params.trial.imgArrPos(:)';      % row vector
    baseSorted = sort(basePos);
    spacingPx = median(diff(baseSorted));
    if ~isfinite(spacingPx) || spacingPx <= 0
        spacingPx = 100; % fallback
    end

    offsetPx = 0;  % smooth sub-slot offset

    movementOnset = vbl0;
    endT = movementOnset + movementDur;
    vbl = vbl0;

    KbReleaseWait;

    while true
        if vbl >= endT
            break;
        end

        % --- update smooth offset ---
        offsetPx = offsetPx + dxPerFrame * params.participant.direction;

        % --- rotate IDs when passing >= 1 slot ---
        stepCount = fix(offsetPx / spacingPx);  % trunc toward 0 (works for +/-)
        if stepCount ~= 0
            offsetPx = offsetPx - stepCount * spacingPx;

            % If direction feels reversed, flip sign here:
            params.trial.imgArrShifted = circshift(params.trial.imgArrShifted, stepCount);
            % params.trial.imgArrShifted = circshift(params.trial.imgArrShifted, -stepCount);
        end

        currPos = basePos + offsetPx;

        % --- draw frame ---
        Screen('FillRect', win, bg);

        for k = 1:n
            xPos = xCenter + currPos(k);
            yPos = yCenter - params.START_Y_PX;

            dstRect = CenterRectOnPointd([0 0 params.LM_WIDTH params.LM_HEIGHT], xPos, yPos);

            currImgId = params.trial.imgArrShifted(k);
            currCatImgId = mod(currImgId - 1, 3) + 1;
            currCatId    = mod(floor((currImgId - 1) / 3), 6) + 1;

            curTex = params.tex{currCatId, currCatImgId};
            Screen('DrawTexture', win, curTex, [], dstRect);
        end

        % Target + fixation
        Screen('DrawTexture', win, params.trial.targetTex, [], params.trial.targetRect);
        dotRect = CenterRectOnPointd([0 0 params.FIX_SIZE_PX params.FIX_SIZE_PX], xCenter, yCenter);
        Screen('FillOval', win, red, dotRect);

        % --- synced flip ---
        vbl = Screen('Flip', win, vbl + 0.5 * ifi);

        % keys
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                sca;
                error('UserAbort:ESC', 'Experiment aborted by user');
            elseif keyCode(KbName('SPACE'))
                userInput = GetSecs;
                movementOffset = userInput;
                % Store final image x-positions
                params.trial.imgArrPos = currPos;
                return;
            end
        end
    end

    movementOffset = GetSecs;
    % Store final image x-positions
    params.trial.imgArrPos = currPos;

end
