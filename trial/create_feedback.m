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
    for k = 1:n
        xPos = params.ptb.xCenter + params.trial.imgArrPos(k);
        yPos = params.ptb.yCenter - params.START_Y_PX;

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

        alpha01 = alpha01.^2;   % or ^3 for sharper center emphasis
        alpha   = round(255 * alpha01);

        % draw with per-image opacity
        Screen('DrawTexture', win, curTex, [], dstRect, [], [], [], [255 255 255 alpha]);
%         Screen('DrawTexture', win, curTex, [], dstRect);
    end

    % Target + fixation
    Screen('FrameRect', win, frameColor, frameRect, frameLineW);

    % draw whatever feedback you need here
    Screen('DrawTexture', win, params.trial.targetTex, [], params.trial.targetRect);
    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 
    feedbackOnset = Screen('Flip', win);
  
    % wait until the absolute time feedbackOnset + feedbackDur
    feedbackOffset = WaitSecs('UntilTime', feedbackOnset + feedbackDur);
    feedbackDa =  feedbackOffset - feedbackOnset;
end
