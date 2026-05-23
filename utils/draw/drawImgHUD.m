function drawImgHUD(params)

    % Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    xCenter = params.ptb.xCenter;
    yCenter = params.ptb.yCenter - params.START_Y_PX;
    dstRect = CenterRectOnPointd( ...
                [0 0 params.LM_WIDTH_PX*1.25 params.LM_HEIGHT_PX*1.25], ...
                 xCenter, yCenter);

    
    Screen('DrawTexture', params.ptb.window, params.startimg_HUD, [], dstRect);

end