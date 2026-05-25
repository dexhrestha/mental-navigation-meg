function [movementOnset, movementOffset, movementDa, targetPos, tp, params] = ...
    create_movement(startId, targetId, speed, movementDur, visual, params, vbl0)

% --------------------------------------------------
% Init
% --------------------------------------------------
if nargin < 7 || isempty(vbl0)
    vbl0 = Screen('Flip', params.ptb.window, [], 1);
end

win      = params.ptb.window;
bg       = params.ptb.BG_COLOR;
xCenter  = params.ptb.xCenter;
yCenter  = params.ptb.yCenter;
ifi      = Screen('GetFlipInterval', win);

movementDur = movementDur / 1000;

tp         = -1;
targetPos  = NaN;
offsetPx   = 0;
showSeq    = true;
initFlag   = true;
totalSteps = 0;  % cumulative sequence wraps, useful for debugging

basePos    = params.trial(params.trialId).imgArrPos(:)';
nImgs      = numel(basePos);

posDiffs = diff(sort(basePos));
spacingPx = median(posDiffs);

if ~isfinite(spacingPx) || spacingPx <= 0
    spacingPx = params.LM_WIDTH_PX + params.ILD_PX;
end

% Warn if item positions are not evenly spaced. Motion can be linear in
% pixels while still looking non-linear across an irregular position array.
if numel(posDiffs) > 1 && any(abs(posDiffs - spacingPx) > 0.01 * spacingPx)
    warning('create_movement:irregularSpacing', ...
        'imgArrPos is not evenly spaced; sequence motion may look non-linear.');
end

speedPxPerSec = speed * spacingPx;

Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% ----------------------------------------------------
% Timing
% ----------------------------------------------------
movementOnset = GetSecs;

endT = movementOnset + movementDur;
vbl = vbl0;
prevVbl = vbl0;
firstFrame = true;

params.trial(params.trialId).startPressed = ...
    check_response(params, params.START_KEY, 1);

if params.is_meg
    trigger_meg_send(params.triggers.MOV_START, 0.005);
end

fixY = yCenter - params.START_Y_PX;

if ~isfield(params, 'FIX_COLOR')
    params.FIX_COLOR = [255 0 0];
end

% --------------------------------------------------
% Main loop
% --------------------------------------------------
nCats = size(params.tex, 1);
nCatImgs = size(params.tex, 2);
 dir = params.participant.direction;

while true

    if vbl >= endT
        movementOffset = vbl;
        tp = movementOffset - movementOnset;
        break;
    end

    Screen('FillRect', win, bg);
    
    % ----------------------------------------------
    % Motion update
    % ----------------------------------------------
    % Use the actual time since the previous flip, not a fixed IFI. This
    % keeps the stimulus velocity linear even if a frame is late/dropped.
    if firstFrame
        dt = 0;
        firstFrame = false;
    else
        dt = vbl - prevVbl;
    end
    
    prevVbl = vbl;
    
    if ~isfinite(dt) || dt <= 0 || dt > 2 * ifi
        dt = ifi;
    end

    offsetPx = offsetPx + speedPxPerSec * dt * dir;

    % Wrap only whole item spacings. fix() is intentional here: it keeps the
    % residual offset signed and bounded in (-spacingPx, spacingPx), which
    % prevents asymmetric jumps for negative motion.
    stepCount = fix(offsetPx / spacingPx);
    % disp(stepCount);

    if stepCount ~= 0
        offsetPx = offsetPx - stepCount * spacingPx;
        totalSteps = totalSteps + stepCount;

        params.trial(params.trialId).imgArrShifted = ...
            circshift(params.trial(params.trialId).imgArrShifted, stepCount);
    end

    currPos = basePos + offsetPx;

    idxStart = ...
        find(params.trial(params.trialId).imgArrShifted == startId, 1);

    
    if isempty(idxStart)
        posOfImageX = Inf;
    else
        posOfImageX = abs(currPos(idxStart));
    end

    idxTarget = ...
        find(params.trial(params.trialId).imgArrShifted == targetId, 1);

    if isempty(idxTarget)
        targetPos = NaN;
    else
        targetPos = currPos(idxTarget);
    end

    showSeq = showSeq && ...
        (posOfImageX < spacingPx * 2);

    initFlag = initFlag && ...
        (posOfImageX < spacingPx);

    % ----------------------------------------------
    % Starfield
    % ----------------------------------------------
    if showSeq || visual

        params.star.speed = ...
            (speedPxPerSec / params.star.focalLength) ...
            * 0.25;

        params.star = ...
            drawHyperspaceStarfield(params);
    end
     % disp(params.trial(params.trialId).imgArrShifted)
    % ----------------------------------------------
    % Draw images
    % ----------------------------------------------
    for k = 1:nImgs

        if params.CENTRAL
            xPos = xCenter;
        else
            xPos = xCenter + currPos(k);
        end

        dstRect = CenterRectOnPointd( ...
            [0 0 ...
            params.LM_WIDTH_PX ...
            params.LM_HEIGHT_PX], ...
            xPos, fixY);

        imgId    = params.trial(params.trialId).imgArrShifted(k);
        imgIdx = mod(imgId - 1, nCatImgs) + 1;
        catIdx = mod(floor((imgId - 1) / nCatImgs), nCats) + 1;

        tex = params.tex{catIdx, imgIdx};
        dist = abs(currPos(k));

        if ~(showSeq || visual)
            continue
        end

        alpha = round(255 * ...
            (1 - min(dist / spacingPx,1))^6);

        visible = true;

        if initFlag

            % Use the sanitized direction from the motion update.
            visible = ...
                (dir == 1  && currPos(k) <= spacingPx) || ...
                (dir == -1 && currPos(k) >= -spacingPx);

        end

        if visible
            Screen('DrawTexture', ...
                win, tex, [], dstRect, ...
                [], [], [], ...
                [255 255 255 alpha]);
        end
    end

    drawImgHUD(params);

    % ----------------------------------------------
    % Fixation
    % ----------------------------------------------
    fixBounds = ...
        Screen('TextBounds', win, '+');

    fixRect = ...
        CenterRectOnPointd( ...
        fixBounds, xCenter, fixY);

    Screen('DrawText', ...
        win, '+', ...
        fixRect(1), ...
        fixRect(2), ...
        params.FIX_COLOR);

    % ----------------------------------------------
    % HUD / bars
    % ----------------------------------------------
    drawHUD(params);

    if params.add_bars
        Screen( ...
            'FillRect', ...
            win, ...
            params.Bars.barColor, ...
            params.Bars.sideBarRects);
    end

    % ----------------------------------------------
    % Flip
    % ----------------------------------------------
    vbl = Screen( ...
        'Flip', ...
        win, ...
        vbl + 0.5 * ifi);

    % ----------------------------------------------
    % Response logic
    % ----------------------------------------------
    pressed = ...
        check_response( ...
        params, ...
        params.START_KEY,1);

    % if pressed
    %     break

    if ~params.trial(params.trialId).startPressed && pressed

        params.trial(params.trialId).startPressed = true;

    elseif params.trial(params.trialId).startPressed && ~pressed

        movementOffset = GetSecs;
        tp = movementOffset - movementOnset;
        break;

    end
end

% --------------------------------------------------
% Final timing
% --------------------------------------------------
if tp < 0
    movementOffset = vbl;
end

% Final released configuration for feedback
finalOffsetPx = offsetPx;
finalImgArrShifted = params.trial(params.trialId).imgArrShifted;
finalCurrPos = basePos + finalOffsetPx;

idxTargetFinal = find(finalImgArrShifted == targetId, 1);

if ~isempty(idxTargetFinal)
    finalTargetPosPx = finalCurrPos(idxTargetFinal);
else
    finalTargetPosPx = NaN;
end

% Store diagnostics / feedback inputs
params.trial(params.trialId).movementTotalSteps = totalSteps;
params.trial(params.trialId).movementFinalOffsetPx = finalOffsetPx;

params.trial(params.trialId).finalOffsetPx = finalOffsetPx;
params.trial(params.trialId).finalImgArrShifted = finalImgArrShifted;
params.trial(params.trialId).finalTargetPosPx = finalTargetPosPx;
params.trial(params.trialId).finalCurrPos = finalCurrPos;

% Store useful diagnostics without changing the function interface.
params.trial(params.trialId).movementTotalSteps = totalSteps;
params.trial(params.trialId).movementFinalOffsetPx = offsetPx;

movementDa = movementOffset - movementOnset;

end