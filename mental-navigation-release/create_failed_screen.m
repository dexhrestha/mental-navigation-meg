function params = create_failed_screen(params)

    win = params.ptb.window;
    bg  = [255 0 0 ];

    % Use the SAME keyboard device as the rest of the experiment
    if isfield(params,'kbdDeviceIndex')
        deviceIndex = params.kbdDeviceIndex;
    else
        deviceIndex = [];
    end

    KbName('UnifyKeyNames');
    spaceKey = KbName('Space');
    escKey   = KbName('ESCAPE');

    welcome_text = sprintf('Failed to press buttons.');

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
    vbl = Screen('Flip', win); %#ok<NASGU>

    % Flush any buffered keys before waiting
    KbQueueFlush(deviceIndex);

    % Wait for SPACE (or ESC)
%     while true
%         [pressed, firstPress] = KbQueueCheck(deviceIndex);
% 
%         if pressed
%             if firstPress(escKey) > 0
%                 error('UserAbort:ESC', 'Experiment aborted by user');
%             elseif firstPress(spaceKey) > 0
%                 break;
%             end
%         end
% 
%         WaitSecs(0.001);
%     end
    WaitSecs(.75);
    % Debounce: flush to avoid SPACE carrying into the next screen
    KbQueueFlush(deviceIndex);

end
