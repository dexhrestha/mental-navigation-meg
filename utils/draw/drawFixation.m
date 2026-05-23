
function drawFixation(params, xPos, yPos)
    win = params.ptb.window;
    fixColor = params.FIX_COLOR;
    Screen('TextSize', win, params.FIX_SIZE_PX);
    fixBounds = Screen('TextBounds', win, '+');
    fixRect = CenterRectOnPointd(fixBounds, xPos, yPos);
    Screen('DrawText', win, '+', fixRect(1), fixRect(2), fixColor);
end