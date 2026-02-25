function stop = checkSpace()
% Returns true if SPACE is pressed

    stop = false;

    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('SPACE'))
        stop = true;
    end
end