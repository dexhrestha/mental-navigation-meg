function [speedCueOnset,speedCueOffset] = create_speed_cue(speed, speedCueDur,params)
    speedCueDur = speedCueDur/1000;
    
    win   = params.window;
    color = params.TEXT_COLOR;
    
    
    
    % Draw speed text
    DrawFormattedText( ...
        win, ...
        sprintf('Speed: %g', speed), ...
        'center', 'center', ...
        color ...
    );

    % Flip to screen and get onset timestamp
    speedCueOnset = Screen('Flip', win);
    
    fprintf('speedCueOnset %g at %g  \n', speed,speedCueOnset);
    fprintf('Wait for %g seconds\n', speedCueDur);
    [speedCueOffset] = WaitSecs(speedCueDur);
    fprintf('speedCueOffset %g\n',speedCueOffset)
end
