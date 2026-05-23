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
        folderpath = fullfile('instructions',params.EXP_MODE ,'ita','instructions');
    else
        folderpath = fullfile('instructions',params.EXP_MODE ,'eng','instructions');
    end

    files = dir(fullfile(folderpath,'*.JPG'));
    
    filepaths = fullfile(folderpath,{files.name});

    for idx = 1:length(filepaths)
         
        imgPath =   filepaths{idx};

        if ~exist(imgPath,'file')
            error('Missing image file: %s', imgPath);
        else

            disp(imgPath);
    
            img = imread(imgPath);
            if size(img,3) == 4
                img = img(:,:,1:3); % drop alpha to avoid invisibility
            end
            
            text_img = Screen('MakeTexture', win, img);
            
            Screen('FillRect', win, bg);
            Screen('DrawTexture', win, text_img);
            
            if params.add_bars
                Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
            end
            
            Screen('Flip', win);
            
            KbQueueFlush(deviceIndex);
            params.startPressed = 0;

            while true
                
                WaitSecs(0.001);
                
                if  check_response(params,params.START_KEY)
                    break;
                end
            end
            WaitSecs(0.001);
            KbQueueFlush(deviceIndex);
            
            Screen('Close', text_img); % IMPORTANT
        end
    end
     

    

end
