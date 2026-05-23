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

basePos    = params.trial.imgArrPos(:)';
nImgs      = numel(basePos);

spacingPx = median(diff(sort(basePos)));

if ~isfinite(spacingPx) || spacingPx <= 0
    spacingPx = params.LM_WIDTH_PX * 2;
end

speedPxPerSec = speed * spacingPx;
dxPerFrame    = speedPxPerSec * ifi;

Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% --------------------------------------------------
% Timing
% --------------------------------------------------
movementOnset = GetSecs;

endT = movementOnset + movementDur;
vbl  = vbl0;

params.trial.startPressed = ...
    check_response(params, params.START_KEY, 1);

if params.ismeg
    trigger_meg_send(params.triggers.MOV_START, 0.005);
end

fixY = yCenter - params.START_Y_PX;

if ~isfield(params, 'FIX_COLOR')
    params.FIX_COLOR = [255 0 0];
end

% --------------------------------------------------
% Main loop
% --------------------------------------------------
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
    offsetPx = offsetPx + ...
        dxPerFrame * params.participant.direction;

    stepCount = fix(offsetPx / spacingPx);

    if stepCount ~= 0
        offsetPx = offsetPx - stepCount * spacingPx;

        params.trial.imgArrShifted = ...
            circshift(params.trial.imgArrShifted, stepCount);
    end

    currPos = basePos + offsetPx;

    idxStart = ...
        find(params.trial.imgArrShifted == startId, 1);

    if isempty(idxStart)
        posOfImageX = Inf;
    else
        posOfImageX = abs(currPos(idxStart));
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

        imgId    = params.trial.imgArrShifted(k);
        imgIdx   = mod(imgId - 1, 3) + 1;
        catIdx   = mod(floor((imgId - 1)/3), 6) + 1;

        tex = params.tex{catIdx, imgIdx};

        if ~(showSeq || visual)
            continue
        end

        dist = abs(currPos(k));

        alpha = round(255 * ...
            (1 - min(dist / spacingPx,1))^6);

        visible = true;

        if initFlag

            dir = params.participant.direction;

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
        params.START_KEY, ...
        1);

    if ~params.trial.startPressed && pressed

        params.trial.startPressed = true;

    elseif params.trial.startPressed && ~pressed

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

movementDa = movementOffset - movementOnset;

end