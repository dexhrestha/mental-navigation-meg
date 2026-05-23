function drawHUD(params)
       
    win = params.ptb.window;
    
    screenRect = Screen('Rect', win);

    yShift = 30; % pixels downward
    dstRect = OffsetRect(screenRect, 0, yShift);
    
    Screen('DrawTexture', win, params.spaceship_HUD, [], dstRect);
end