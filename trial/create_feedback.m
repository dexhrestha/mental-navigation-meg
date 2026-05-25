function [feedbackOnset, feedbackOffset, feedbackDa, params] = create_feedback(feedbackDur, params)
%CREATE_FEEDBACK Draw feedback after movement.
%
% Key update:
%   The image shown at the centre is selected directionally, matching the
%   release logic used in create_movement:
%       direction ==  1 -> choose the item that has just crossed/passed
%                         the centre from the positive side, i.e. currPos <= 0
%                         and closest to zero.
%       direction == -1 -> choose the item that has just crossed/passed
%                         the centre from the negative side, i.e. currPos >= 0
%                         and closest to zero.
%
% This avoids inconsistent feedback when two images are similarly close to
% the centre boundary.

feedbackDur = feedbackDur / 1000;

win = params.ptb.window;
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% --------------------------------------------------
% Geometry / spacing
% --------------------------------------------------
basePos = params.trial(params.trialId).imgArrPos(:)';  % row vector
n = numel(basePos);

baseSorted = sort(basePos);
spacingPx = median(diff(baseSorted));

if ~isfinite(spacingPx) || spacingPx <= 0
    spacingPx = params.LM_WIDTH_PX * 2;  % fallback
end

lmWidthPx = params.LM_WIDTH_PX;
if ~isfinite(lmWidthPx) || lmWidthPx <= 0
    lmWidthPx = spacingPx;
end

centerX = params.ptb.xCenter;
centerY = params.ptb.yCenter - params.START_Y_PX;
yPos = centerY;

% Feedback should describe the final released configuration. If movement
% stored a final sub-slot offset, use it. Otherwise default to zero.
offsetPx = 0;
if isfield(params.trial(params.trialId), 'finalOffsetPx') && ...
        isfinite(params.trial(params.trialId).finalOffsetPx)
    offsetPx = params.trial(params.trialId).finalOffsetPx;
elseif isfield(params.trial(params.trialId), 'releaseOffsetPx') && ...
        isfinite(params.trial(params.trialId).releaseOffsetPx)
    offsetPx = params.trial(params.trialId).releaseOffsetPx;
end

if isfield(params.trial(params.trialId), 'finalCurrPos') && ...
        numel(params.trial(params.trialId).finalCurrPos) == numel(basePos)
    currPos = params.trial(params.trialId).finalCurrPos;
else
    currPos = basePos + offsetPx;
end

% --------------------------------------------------
% Directional centre-image selection
% --------------------------------------------------
dir = params.participant.direction;
if ~isfinite(dir) || dir == 0
    dir = 1;
end
dir = sign(dir);

if dir == 1
    eligible = currPos <= 0;
    if any(eligible)
        eligibleIdx = find(eligible);
        [~, relIdx] = max(currPos(eligible));  % closest to 0 from <= 0
        centerIdx = eligibleIdx(relIdx);
    else
        [~, centerIdx] = min(abs(currPos));    % fallback
    end
else
    eligible = currPos >= 0;
    if any(eligible)
        eligibleIdx = find(eligible);
        [~, relIdx] = min(currPos(eligible));  % closest to 0 from >= 0
        centerIdx = eligibleIdx(relIdx);
    else
        [~, centerIdx] = min(abs(currPos));    % fallback
    end
end

centerImgId = params.trial(params.trialId).imgArrShifted(centerIdx);

% Save diagnostics for later inspection.
params.trial(params.trialId).feedbackCenterIdx = centerIdx;
params.trial(params.trialId).feedbackCenterImgId = centerImgId;
params.trial(params.trialId).feedbackCenterPosPx = currPos(centerIdx);
params.trial(params.trialId).feedbackDirection = dir;

% --------------------------------------------------
% Draw sequence with distance-based alpha
% --------------------------------------------------
Screen('FillRect', win, params.ptb.BG_COLOR);

fadeRadius = spacingPx * 2;
nCats = size(params.tex, 1);
nCatImgs = size(params.tex, 2);

for k = 1:n
    if params.CENTRAL
        xPos = centerX;
    else
        xPos = centerX + currPos(k);
    end

    dstRect = CenterRectOnPointd( ...
        [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
        xPos, yPos);

    currImgId = params.trial(params.trialId).imgArrShifted(k);
    currCatImgId = mod(currImgId - 1, nCatImgs) + 1;
    currCatId = mod(floor((currImgId - 1) / nCatImgs), nCats) + 1;

    curTex = params.tex{currCatId, currCatImgId};

    dist = abs(currPos(k));
    alpha01 = 1 - min(dist / fadeRadius, 1);
    alpha01 = alpha01 ^ 8;
    alpha = round(255 * alpha01);

    Screen('DrawTexture', win, curTex, [], dstRect, [], [], [], [255 255 255 alpha]);
end

% --------------------------------------------------
% Force the directionally selected image at exact centre, full alpha
% --------------------------------------------------
centerCatImgId = mod(centerImgId - 1, 2) + 1;
centerCatId = mod(floor((centerImgId - 1) / 2), 9) + 1;
centerTex = params.tex{centerCatId, centerCatImgId};

centerImgRect = CenterRectOnPointd( ...
    [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
    centerX, yPos);

Screen('DrawTexture', win, centerTex, [], centerImgRect, [], [], [], [255 255 255 255]);

% --------------------------------------------------
% Landing / target error
% --------------------------------------------------
landingPx = 0;
if isfield(params.trial(params.trialId), 'targetId') && ...
        ~isempty(params.trial(params.trialId).targetId)

    idxTarget = find( ...
        params.trial(params.trialId).imgArrShifted == ...
        params.trial(params.trialId).targetId, 1);

    if ~isempty(idxTarget) && idxTarget <= numel(currPos)
        landingPx = currPos(idxTarget);
    end
end

landingLm = landingPx / params.LM_WIDTH_PX;

signedLm = landingLm * dir;
absLm = abs(signedLm);

params.trial(params.trialId).feedbackLandingPx = landingPx;
params.trial(params.trialId).feedbackSignedLm = signedLm;

% --------------------------------------------------
% Target / starfield / feedback bar
% --------------------------------------------------
if isfield(params.trial(params.trialId), 'targetTex') && ...
        isfield(params.trial(params.trialId), 'targetRect')
    Screen('DrawTexture', win, ...
        params.trial(params.trialId).targetTex, [], ...
        params.trial(params.trialId).targetRect);
end

drawHyperspaceStarfield(params, 0);

centerBarY = centerY - round(1.1 * params.LM_HEIGHT_PX);
centerBarH = max(8, round(0.08 * params.LM_HEIGHT_PX));
centerLineH = max(26, round(0.35 * params.LM_HEIGHT_PX));

green = [0 220 0];
yellow = [235 210 0];
red = [220 0 0];
white = [255 255 255];

if absLm < 1
     % Bar spans +/- 1 landmark around center
    barHalfW = round(lmWidthPx);
    barRect = CenterRectOnPointd([0 0 barHalfW * 2 centerBarH], centerX, centerBarY);
    
    Screen('FillRect', win, [80 80 80], barRect);
    Screen('FrameRect', win, white, barRect, 2);
    
    % Center reference line
    % Screen('FillRect', win, white, ...
    %     [centerX - 1, centerBarY - centerLineH/2, centerX + 1, centerBarY + centerLineH/2]);
    
    % Green marker: signed landing distance from center, clipped to bar
    seekX = centerX + max(-barHalfW, min(barHalfW, round(-landingPx)));   
    
    seekHalfW = max(3, round(0.035 * lmWidthPx));
    seekRect = [ ...
        seekX - seekHalfW, centerBarY - centerBarH / 2, ...
        seekX + seekHalfW, centerBarY + centerBarH / 2];
    
    Screen('FillRect', win, green, seekRect);

elseif absLm <= 2
    if signedLm >= 0
        txt = '+1';
    else
        txt = '-1';
    end
    DrawFormattedText(win, txt, 'center', ...
        centerBarY - round(0.8 * params.LM_HEIGHT_PX), yellow);

elseif absLm <= 3
    if signedLm >= 0
        txt = '+2';
    else
        txt = '-2';
    end
    DrawFormattedText(win, txt, 'center', ...
        centerBarY - round(0.8 * params.LM_HEIGHT_PX), red);

else
    crossSize = round(0.5 * params.LM_HEIGHT_PX);
    crossY = centerY;

    Screen('DrawLine', win, red, ...
        centerX - crossSize, crossY - crossSize, ...
        centerX + crossSize, crossY + crossSize, 7);

    Screen('DrawLine', win, red, ...
        centerX - crossSize, crossY + crossSize, ...
        centerX + crossSize, crossY - crossSize, 7);
end

% --------------------------------------------------
% HUD / bars
% --------------------------------------------------
drawHUD(params);

if params.add_bars
    Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
end

% --------------------------------------------------
% Flip and hold feedback
% --------------------------------------------------
% --------------------------------------------------
% Capture feedback frame before Flip
% --------------------------------------------------
saveFeedbackImage = true;

if isfield(params, 'saveFeedbackImage')
    saveFeedbackImage = params.saveFeedbackImage;
end

feedbackImg = [];

if saveFeedbackImage
    % Capture the back buffer: this is the image that Screen('Flip')
    % is about to show on screen.
    feedbackImg = Screen('GetImage', win, [], 'backBuffer');
end

% --------------------------------------------------
% Flip and hold feedback
% --------------------------------------------------
feedbackOnset = Screen('Flip', win);
feedbackOffset = WaitSecs('UntilTime', feedbackOnset + feedbackDur);
feedbackDa = feedbackOffset - feedbackOnset;

% --------------------------------------------------
% Save captured feedback image after timing-critical display
% --------------------------------------------------
if saveFeedbackImage && ~isempty(feedbackImg)

    if isfield(params, 'feedbackImageDir') && ~isempty(params.feedbackImageDir)
        outDir = params.feedbackImageDir;
    else
        outDir = fullfile(pwd, 'feedback_screenshots');
    end

    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    outName = sprintf('feedback_trial%04d_%s.png', ...
        params.trialId, datestr(now, 'yyyymmdd_HHMMSSFFF'));

    outPath = fullfile(outDir, outName);

    imwrite(feedbackImg, outPath);

    params.trial(params.trialId).feedbackImagePath = outPath;
end
end
