function [params] = create_img_seq(sampleDur, startId, params)
% Display the initial image sequence using the same presentation style as
% create_sample, without drawing a target image.

sampleDur = sampleDur / 1000;

xCenter = params.ptb.xCenter;
yCenter = params.ptb.yCenter;

imgArr = 1:params.n_images;
N = numel(imgArr);
centerIdx = ceil(N / 2) + 1;

currIdx = find(imgArr == startId, 1);
shiftAmount = centerIdx - currIdx;
params.trial(params.trialId).imgArrShifted = circshift(imgArr, shiftAmount);

params.trial(params.trialId).imgArrPos = ...
    ((1:N) - centerIdx) * (params.LM_WIDTH_PX + params.ILD_PX);

spacingPx = params.LM_WIDTH_PX * 2;

nImgs = numel(params.trial(params.trialId).imgArrPos);
params.trial(params.trialId).rects = cell(1, nImgs);

win = params.ptb.window;
bg  = params.ptb.BG_COLOR;

if ~isfield(params, 'star') || isempty(params.star)
    params = setup_stars(params);
end

if ~isfield(params, 'spaceship_HUD') || ...
        ~isfield(params, 'startimg_HUD')
    params = setup_HUD(params);
end

if ~isfield(params, 'FIX_COLOR')
    params.FIX_COLOR = [0 255 0];
end

Screen('FillRect', win, bg);
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

yPos = yCenter - params.START_Y_PX;

params.star = drawHyperspaceStarfield(params, 0);

nCats = size(params.tex, 1);
nCatImgs = size(params.tex, 2);

direction = 0;
if isfield(params, 'participant') && ...
        isfield(params.participant, 'direction')
    direction = params.participant.direction;
end

for k = 1:nImgs

    if params.CENTRAL
        xPos = xCenter;
    else
        xPos = xCenter + params.trial(params.trialId).imgArrPos(k);
    end

    params.trial(params.trialId).rects{k} = CenterRectOnPointd( ...
        [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
        xPos, yPos);

    currImgId = params.trial(params.trialId).imgArrShifted(k);
    currCatImgId = mod(currImgId - 1, nCatImgs) + 1;
    currCatId = mod(floor((currImgId - 1) / nCatImgs), nCats) + 1;

    curTex = params.tex{currCatId, currCatImgId};
    dist = abs(params.trial(params.trialId).imgArrPos(k));

    alpha01 = 1 - min(dist / spacingPx, 1);
    alpha = round(255 * (alpha01 ^ 8));

    visible = ...
        direction == 0 || ...
        (direction == 1 && params.trial(params.trialId).imgArrPos(k) <= 0) || ...
        (direction == -1 && params.trial(params.trialId).imgArrPos(k) >= 0);

    if visible && alpha > 0
        Screen('DrawTexture', ...
            win, curTex, [], params.trial(params.trialId).rects{k}, ...
            [], [], [], [255 255 255 alpha]);
    end
end

drawImgHUD(params);

Screen('TextSize', win, params.FIX_SIZE_PX);
fixY = yCenter - params.START_Y_PX;
fixBounds = Screen('TextBounds', win, '+');
fixRect = CenterRectOnPointd(fixBounds, xCenter, fixY);
Screen('DrawText', win, '+', fixRect(1), fixRect(2), params.FIX_COLOR);

drawHUD(params);

if params.add_bars
    Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
end

params.trial(params.trialId).imgSeqOnset = Screen('Flip', win, [], 1);

KbName('UnifyKeyNames');

params.trial(params.trialId).startPressed = 0;
sampleEnd = params.trial(params.trialId).imgSeqOnset + sampleDur;

while GetSecs < sampleEnd
    pressed = check_response(params, params.START_KEY);

    if ~params.trial(params.trialId).startPressed && pressed ~= 0
        params.trial(params.trialId).startPressed = pressed;
    elseif params.trial(params.trialId).startPressed && pressed == 0
        params.trial(params.trialId).startPressed = pressed;
        break;
    end

    WaitSecs(0.001);
end

params.trial(params.trialId).imgSeqOffset = GetSecs;
params.trial(params.trialId).imgSeqDa = ...
    params.trial(params.trialId).imgSeqOffset - params.trial(params.trialId).imgSeqOnset;

end
