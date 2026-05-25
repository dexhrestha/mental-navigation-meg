function [params] = create_navigation(speed, params)
% User-controlled navigation aligned with the create_movement render loop.
speed = 1;
vbl0 = Screen('Flip', params.ptb.window, [], 1);

deviceIndex = params.kbdDeviceIndex;

win     = params.ptb.window;
bg      = params.ptb.BG_COLOR;
xCenter = params.ptb.xCenter;
yCenter = params.ptb.yCenter;
ifi     = Screen('GetFlipInterval', win);

basePos  = params.trial(params.trialId).imgArrPos(:)';
currPos  = basePos;
nImgs    = numel(basePos);
offsetPx = 0;

spacingPx = median(diff(sort(basePos)));

if ~isfinite(spacingPx) || spacingPx <= 0
    spacingPx = params.LM_WIDTH_PX * 2;
end

speedPxPerSec = speed * spacingPx;
dxPerFrame    = speedPxPerSec * ifi;

if ~isfield(params, 'FIX_COLOR')
    params.FIX_COLOR = [255 0 0];
end

if ~isfield(params, 'star') || isempty(params.star)
    params = setup_stars(params);
end

if ~isfield(params, 'spaceship_HUD') || ...
        ~isfield(params, 'startimg_HUD')
    params = setup_HUD(params);
end

fixY = yCenter - params.START_Y_PX;

KbName('UnifyKeyNames');
kStop = KbName('b');
escKey = KbName('ESCAPE');

KbReleaseWait;
vbl = vbl0;
startTime = GetSecs;

Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

nCats = size(params.tex, 1);
nCatImgs = size(params.tex, 2);
direction = params.participant.direction;
pressed = 0 ;  


while true

    if GetSecs - startTime > 5 * 60
        break;
    end

    [keyIsDown, ~, keyCode] = KbCheck(deviceIndex);

    if keyIsDown && keyCode(escKey)
        error('UserAbort:ESC', 'Experiment aborted by user');
    end

    % Move only while kStop is held
    pressed = check_response(params, kStop, 1);

    if pressed
        direction = params.participant.direction;
    else
        direction = 0;
    end

    Screen('FillRect', win, bg);

    offsetPx = offsetPx + dxPerFrame * direction;

    stepCount = fix(offsetPx / spacingPx);

    if stepCount ~= 0
        offsetPx = offsetPx - stepCount * spacingPx;
        params.trial(params.trialId).imgArrShifted = ...
            circshift(params.trial(params.trialId).imgArrShifted, stepCount);
    end

    currPos = basePos + offsetPx;

    params.star.speed = ...
        (speedPxPerSec / params.star.focalLength) * 0.25;

    params.star = drawHyperspaceStarfield(params, direction ~= 0);

    for k = 1:nImgs

        if params.CENTRAL
            xPos = xCenter;
        else
            xPos = xCenter + currPos(k);
        end

        dstRect = CenterRectOnPointd( ...
            [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
            xPos, fixY);

        imgId  = params.trial(params.trialId).imgArrShifted(k);
        imgIdx = mod(imgId - 1, nCatImgs) + 1;
        catIdx = mod(floor((imgId - 1) / nCatImgs), nCats) + 1;

        tex = params.tex{catIdx, imgIdx};
        dist = abs(currPos(k));

        alpha = round(255 * ...
            (1 - min(dist / spacingPx, 1)) ^ 6);

        if alpha > 0
            Screen('DrawTexture', ...
                win, tex, [], dstRect, ...
                [], [], [], ...
                [255 255 255 alpha]);
        end
    end

    drawImgHUD(params);
    drawFixation(params, xCenter, fixY);
    drawHUD(params);

    if params.add_bars
        Screen( ...
            'FillRect', ...
            win, ...
            params.Bars.barColor, ...
            params.Bars.sideBarRects);
    end

    vbl = Screen( ...
        'Flip', ...
        win, ...
        vbl + 0.5 * ifi);
end

params.trial(params.trialId).imgArrPos = currPos;

end
