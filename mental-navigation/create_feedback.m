function [feedbackOnset,feedbackOffset,params] = create_feedback(feedbackDur, params)
    feedbackDur = feedbackDur/1000;
    
    win = params.ptb.window;
    n = numel(params.trial.imgArrPos);
    
    for k = 1:n
        xPos = params.ptb.xCenter + params.trial.imgArrPos(k);
        yPos = params.ptb.yCenter - params.START_Y_PX;

        dstRect = CenterRectOnPointd([0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], xPos, yPos);

        currImgId = params.trial.imgArrShifted(k);
        currCatImgId = mod(currImgId - 1, 3) + 1;
        currCatId    = mod(floor((currImgId - 1) / 3), 6) + 1;

        curTex = params.tex{currCatId, currCatImgId};
        Screen('DrawTexture', win, curTex, [], dstRect);
    end

    % Target + fixation
    Screen('DrawTexture', win, params.trial.targetTex, [], params.trial.targetRect);
    
    % draw whatever feedback you need here
    Screen('DrawTexture', win, params.trial.targetTex, [], params.trial.targetRect);
    feedbackOnset = Screen('Flip', win);
  
    % wait until the absolute time feedbackOnset + feedbackDur
    feedbackOffset = WaitSecs('UntilTime', feedbackOnset + feedbackDur);
    
end
