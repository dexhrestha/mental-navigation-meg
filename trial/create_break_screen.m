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
    respKey = KbName('b'); 
    
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
    if params.lang == 1
        welcome_text = sprintf('Fai una pausa di un minuto per riposare gli occhi.');
    else

        welcome_text = sprintf('Please take one minute break to rest your eyes.');
    end
    DrawFormattedText(win, welcome_text, 'center', 'center', txtColor);

    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 
    
    vbl = Screen('Flip', win);  
    
    % Flush any buffered keys before waiting
%     KbQueueFlush(deviceIndex);

    % Wait for SPACE (or ESC)
%     if params.ismeg || params.iseye
%         while true
%             [pressed, firstPress] = KbQueueCheck(deviceIndex);
%     
%             if pressed
%                 if firstPress(respKey) > 0
%                     break;
%                 end
%             end
%     
%             WaitSecs(0.001);
%         end
%     else
    % in seconds
%     end
    WaitSecs(params.BREAK_DUR); 
    % Debounce: flush to avoid SPACE carrying into the next screen
    KbQueueFlush(deviceIndex);
    
end
