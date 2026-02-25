
    sca;    
    try
        %% setup psychotoolbox if screen not found
        if exist('Screen') ~=3
            if params.ismeg
%                 run 'C:\Users\auditory_vo\Desktop\eyetrackerPsychtoolbox\Psychtoolbox_32\SetupPsychtoolbox.m';
                run 'C:\Toolboxes\PTB\Psychtoolbox_matlab_2025_a_no_license\Psychtoolbox\SetupPsychtoolbox.m';
            elseif  params.iseye
               run 'C:\Users\Eyelink\Desktop\Psychtoolbox_32\SetupPsychtoolbox.m'
            else 
                if params.DEV_MODE
                    run '/Applications/Psychtoolbox/SetupPsychtoolbox.m';
                end 
            end 
        end 
        
        
        if ~params.ismeg
            Screen('Preference', 'SkipSyncTests', 0); %SKIP SYNCH TEST
        else
            Screen('Preference', 'SkipSyncTests', 0);
        end

        % Here we call some default settings for setting up Psychtoolbox
        PsychDefaultSetup(2);
        
        params.ptb =struct();
        % Get the screen numbers
        screens = Screen('Screens');

        % Draw to the external screen if avaliable
        if params.ismeg
            params.ptb.screenNumber = 1;
            params.ptb.screenNumber = max(screens);
        else
            params.ptb.screenNumber = max(screens);
        end

        %
        params.ptb.BG_COLOR = [64 64 64];      % gray background
        params.ptb.FG_COLOR = [255 255 255];   % white foreground

        % Open an on screen window
        if params.DEV_MODE
            [params.ptb.window, params.ptb.windowRect] = Screen('OpenWindow', params.ptb.screenNumber , params.ptb.BG_COLOR, [0 0 800 600]);
        else
            [params.ptb.window, params.ptb.windowRect] = Screen('OpenWindow', params.ptb.screenNumber , params.ptb.BG_COLOR);
        end

        %set text size
        %if params.ismeg
        %   Screen('TextSize', window, 20);
        %elseif ismac
        %   Screen('TextSize', window, 20);
        %else
        %   Screen('TextSize', window, 12); % this is because of weird 2012b
        %end

        % set font to courier, given monospaced
        Screen('TextFont', params.ptb.window, params.FONT_FAMILY);

        % Get the size of the on screen window
        [params.ptb.screenXpixels, params.ptb.screenYpixels] = Screen('WindowSize', params.ptb.window);

        % Query the frame duration
        ifi = Screen('GetFlipInterval', params.ptb.window);

        % Get the centre coordinate of the window
        [xCenter, yCenter] = RectCenter(params.ptb.windowRect);

        % diode position
        params.ptb.diode = [0 0 30 30]; 
        
        % Maximum priority level
        topPriorityLevel = MaxPriority(params.ptb.window);
        Priority(topPriorityLevel);
        
        % hide mouse pointer
        if params.ismeg || params.iseye
            HideCursor(params.ptb.window)
        end

        %% organize everything in a structure for ease of output
        % circle
        params.ptb.xCenter = xCenter;
        params.ptb.yCenter = yCenter;
        %params.ptb.radius = r;
%         params.ptb.innercolor = [125 255 125]; % color of the fixation window
%         params.ptb.r_fix = r_fix;
        %params.ptb.r_test = r_test;
        % stimuli
        %params.ptb.rect_color = rectColor;
        %params.ptb.dot_color = dotColor;
        % letters
%         params.ptb.defaultfontsize = Screen('TextSize', window);
        % timing 
        params.ptb.wait_frames = 1;
        params.ptb.ifi = ifi;
        
        
    catch ME
        sca;
        rethrow(ME);
    end
