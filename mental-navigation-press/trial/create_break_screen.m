function params = create_break_screen(params)
 
    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;

    % Use the SAME keyboard device as the rest of the experiment
    if isfield(params,'kbdDeviceIndex')
        deviceIndex = params.kbdDeviceIndex;
    else
        deviceIndex = [];
    end

    KbName('UnifyKeyNames');
    spaceKey = KbName('Space'); 
    
    % Draw welcome screen
    Screen('FillRect', win, bg);
    
    % Optional: set text properties if you have them in params
    if isfield(params,'TEXT_SIZE_PX'), Screen('TextSize', win, params.TEXT_SIZE_PX); end
    if isfield(params,'TEXT_FONT'), Screen('TextFont', win, params.TEXT_FONT); end
    if isfield(params,'TEXT_COLOR')
        txtColor = params.TEXT_COLOR;
    else
       txtColor = params.ptb.FG_COLOR;
    end
    welcome_text = sprintf('Please take one minute break to rest your eyes.');

    DrawFormattedText(win, welcome_text, 'center', 'center', txtColor);
    vbl = Screen('Flip', win);  

    % Flush any buffered keys before waiting
    KbQueueFlush(deviceIndex);

    % Wait for SPACE (or ESC)
    if params.ismeg || params.iseye
        while true
            [pressed, firstPress] = KbQueueCheck(deviceIndex);
    
            if pressed
                if firstPress(spaceKey) > 0
                    break;
                end
            end
    
            WaitSecs(0.001);
        end
    else
        WaitSecs(params.BREAK_DUR); % in seconds
    end
    % Debounce: flush to avoid SPACE carrying into the next screen
    KbQueueFlush(deviceIndex);

end
