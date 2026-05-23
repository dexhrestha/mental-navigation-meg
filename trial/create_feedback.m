function [feedbackOnset,feedbackOffset,feedbackDa,params] = create_feedback(feedbackDur, params)
    feedbackDur = feedbackDur/1000;
    win = params.ptb.window;
    n = numel(params.trial.imgArrPos);
    
    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    
    basePos = params.trial.imgArrPos(:)';      % row vector
    baseSorted = sort(basePos);
    spacingPx = median(diff(baseSorted));
    
    if ~isfinite(spacingPx) || spacingPx <= 0
        spacingPx = params.LM_WIDTH_PX*2; % fallback
    end
    
    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    offsetPx = 0;  % smooth sub-slot offset
    framePad = 6;                 % px padding around image (tune)
    frameLineW = 5;               % border thickness (tune)
    frameColor = [255 0 0];   % frame color (white)

    centerX = params.ptb.xCenter;
    centerY = params.ptb.yCenter - params.START_Y_PX;

    frameRect = CenterRectOnPointd( ...
        [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
        centerX, centerY);

    % add padding
    frameRect = frameRect + [-framePad -framePad framePad framePad];
    currPos = basePos + offsetPx;
    yPos = params.ptb.yCenter - params.START_Y_PX;

    minDist = inf;
    centerIdx = 1;
    for k = 1:n
        if params.CENTRAL
           xPos = params.ptb.xCenter;
        else
            xPos = params.ptb.xCenter + params.trial.imgArrPos(k);
        end


        dstRect = CenterRectOnPointd([0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], xPos, yPos);

        currImgId = params.trial.imgArrShifted(k);
        currCatImgId = mod(currImgId - 1, 3) + 1;
        currCatId    = mod(floor((currImgId - 1) / 3), 6) + 1;

        curTex = params.tex{currCatId, currCatImgId};
        
        dist = abs(currPos(k));   % because currPos is relative to center already

        % choose a falloff radius (tune this)
        fadeRadius = spacingPx * 2;   % e.g., fully visible within ~2 slots

        % map distance -> alpha in [0..255]
        alpha01 = 1 - min(dist / fadeRadius, 1);   % 1 at center, 0 far away
%         alpha   = round(255 * alpha01);

        alpha01 = alpha01.^8;   % or ^3 for sharper center emphasis
        alpha   = round(255 * alpha01);
        % alpha = 255;

        if dist < minDist
            minDist = dist;
            centerIdx = k;
        end

        % draw with per-image opacity
        Screen('DrawTexture', win, curTex, [], dstRect, [], [], [], [255 255 255 alpha]);
    end
    landingPx = 0;
    if isfield(params.trial, 'targetId') && ~isempty(params.trial.targetId)
        idxTarget = find(params.trial.imgArrShifted == params.trial.targetId, 1);
        if ~isempty(idxTarget) && idxTarget <= numel(currPos)
            landingPx = currPos(idxTarget);
        end
    end

    centerImgId = params.trial.imgArrShifted(centerIdx);
    centerCatImgId = mod(centerImgId - 1, 3) + 1;
    centerCatId = mod(floor((centerImgId - 1) / 3), 6) + 1;
    centerTex = params.tex{centerCatId, centerCatImgId};
    centerImgRect = CenterRectOnPointd([0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], centerX, yPos);
    Screen('DrawTexture', win, centerTex, [], centerImgRect, [], [], [], [255 255 255 255]);

    lmWidthPx = params.LM_WIDTH_PX;
    if ~isfinite(lmWidthPx) || lmWidthPx <= 0
        lmWidthPx = spacingPx;
    end
    % landingLm = landingPx / ( params.LM_WIDTH_PX + params.ILD_PX );
    landingLm = landingPx / ( params.LM_WIDTH_PX  );
    signedLm = landingLm * params.participant.direction;
    absLm = abs(signedLm);

    % Target + fixation
    % Screen('FrameRect', win, frameColor, frameRect, frameLineW);

    % draw whatever feedback you need here
    Screen('DrawTexture', win, params.trial.targetTex, [], params.trial.targetRect);
    drawHyperspaceStarfield(params,0);
    centerBarY = centerY - round(1.1 * params.LM_HEIGHT_PX);
    centerBarHalfW = round(2.0 * lmWidthPx);
    centerBarH = max(8, round(0.08 * params.LM_HEIGHT_PX));
    centerLineH = max(26, round(0.35 * params.LM_HEIGHT_PX));
    green = [0 220 0];
    yellow = [235 210 0];
    red = [220 0 0];
    white = [255 255 255];

    if absLm <= 1
        barHalfW = round(lmWidthPx / 2);
        barRect = CenterRectOnPointd([0 0 barHalfW * 2 centerBarH], centerX, centerBarY);
        Screen('FrameRect', win, white, barRect, 2);
        Screen('FillRect', win, [80 80 80], barRect);
        Screen('DrawLine', win, white, centerX, centerBarY - centerLineH, centerX, centerBarY + centerLineH, 3);

        seekX = centerX + max(-barHalfW, min(barHalfW, round(landingPx)));
        seekHalfW = max(2, round(0.03 * lmWidthPx));
        seekRect = [seekX - seekHalfW, centerBarY - centerBarH / 2, seekX + seekHalfW, centerBarY + centerBarH / 2];
        Screen('FillRect', win, green, seekRect);
    elseif absLm <= 2
        if signedLm >= 0
            txt = '+1';
        else
            txt = '-1';
        end
        DrawFormattedText(win, txt, 'center', centerBarY - round(0.45 * params.LM_HEIGHT_PX), yellow);
    elseif absLm <= 3
        if signedLm >= 0
            txt = '+2';
        else
            txt = '-2';
        end
        DrawFormattedText(win, txt, 'center', centerBarY - round(0.45 * params.LM_HEIGHT_PX), red);
    else
        crossSize = round(0.5* params.LM_HEIGHT_PX);
        crossY = centerY;
        Screen('DrawLine', win, red, centerX - crossSize, crossY - crossSize, centerX + crossSize, crossY + crossSize, 7);
        Screen('DrawLine', win, red, centerX - crossSize, crossY + crossSize, centerX + crossSize, crossY - crossSize, 7);
    end

    drawHUD(params);
    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 
    feedbackOnset = Screen('Flip', win);
    
    pressed = check_response(params,params.START_KEY)
    % wait until the absolute time feedbackOnset + feedbackDur
    feedbackOffset = WaitSecs('UntilTime', feedbackOnset + feedbackDur);
    

    % KbName('UnifyKeyNames');
    % escKey = KbName('ESCAPE');
    % while true
        % [keyIsDown, ~, keyCode] = KbCheck(params.kbdDeviceIndex);
        % if keyIsDown && keyCode(escKey)
        %     sca;
        %     error('UserAbort:ESC', 'Experiment aborted by user');
        % end
        % if ~keyIsDown
        %     break;
        % end
        % WaitSecs(0.01);
    % end

    feedbackDa =  feedbackOffset - feedbackOnset;
end
