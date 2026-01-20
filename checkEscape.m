function checkEscape()
    [keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        sca;
        error('Experiment aborted by user');
    end
end