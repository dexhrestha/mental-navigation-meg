function params = create_instruction_screen(params)

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
        folderpath = fullfile('instructions' ,'ita');
    else
        folderpath = fullfile('instructions' ,'eng');
    end

    files  = dir(fullfile(folderpath,'*.PNG'));
    filepaths = fullfile(folderpath,{files.name});
   
    for idx = 1:length(filepaths)
         
        imgPath =   filepaths{idx};

        if ~exist(imgPath,'file')
            error('Missing image file: %s', imgPath);
        else
        disp(imgPath);
        img = imread(imgPath);
        text_img = Screen('MakeTexture', params.ptb.window, img);
        % Draw welcome screen
        Screen('FillRect', win, bg);
        
        Screen('DrawTexture',win,text_img);
        
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

    end
     

    

end
