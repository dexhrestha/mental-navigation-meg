function params = create_welcome_screen(params)

    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;

    % Use the SAME keyboard device as the rest of the experiment
    if isfield(params,'kbdDeviceIndex')
        deviceIndex = params.kbdDeviceIndex;
    else
        deviceIndex = [];
    end

    KbName('UnifyKeyNames');
    respKey = KbName('b');
    escKey   = KbName('ESCAPE');
    if params.lang == 1
        welcome_text = sprintf('Benvenuto all’esperimento\nPremi b per continuare\n(Premi ESC per uscire)');
    else
        welcome_text = sprintf('Welcome to the experiment\n\nPress b to continue\n(Press ESC to quit)');
    end

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
    
    DrawFormattedText(win, welcome_text, 'center', 'center', txtColor);

    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 

    vbl = Screen('Flip', win);  

    % Flush any buffered keys before waiting
    KbQueueFlush(deviceIndex);

    % Wait for SPACE (or ESC)
    while true
        [pressed, firstPress] = KbQueueCheck(deviceIndex);

        if pressed
            if firstPress(escKey) > 0
                error('UserAbort:ESC', 'Experiment aborted by user');
            elseif firstPress(respKey) > 0
                break;
            end
        end
        
        WaitSecs(0.001);
    end

    % Debounce: flush to avoid SPACE carrying into the next screen
    KbQueueFlush(deviceIndex);

end
