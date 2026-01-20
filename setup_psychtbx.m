function params = setup_psychtbx(params)
    sca;    
    try
        Screen('Preference', 'SkipSyncTests', 0); 
        PsychDefaultSetup(2);

        %% setup screen
        params.screens = Screen('Screens');
        params.screenNumber = max(params.screens);

        white = WhiteIndex(params.screenNumber);
        black = BlackIndex(params.screenNumber);
        grey = (white + black) / 2; 
        params.BG_COLOR = grey;
        
        if params.DEV_MODE
            [params.window, params.windowRect] = Screen('OpenWindow', params.screenNumber, params.BG_COLOR, [0 0 800 600]);
        else
            [params.window, params.windowRect] = Screen('OpenWindow', params.screenNumber, params.BG_COLOR);
        end
    catch ME
        sca;
        rethrow(ME);
    end
