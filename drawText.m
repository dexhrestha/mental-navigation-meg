
function drawText(params, xPos, yPos,text,textSize,textColor)
    win = params.ptb.window;
    Screen('TextSize', win, textSize);
    fixBounds = Screen('TextBounds', win, text);
    fixRect = CenterRectOnPointd(fixBounds, xPos, yPos);
    Screen('DrawText', win, text, fixRect(1), fixRect(2), textColor);
end