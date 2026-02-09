%% eye tracker
% percentage of time of a trial that the participant has to fixate in the
% window
params.eye.fix_perc = .8;
% amount of time that participants need to fixate within the window to
% start the trial
params.eye.fixationTime = 1; %in seconds
% maximum fixation time to start the trial, after which we can start the
% trial manually (this is used in case of problems)
params.eye.maxFixationTime = 10;
% whether to simulate eye using mouse
params.eye.simulate_eye = 0;
% eye to track, 0: left, 1: right, 2: both
params.eye.eye_used = 1;
% save it also as string to be used in eye tracker initialization
if params.eye.eye_used == 0
    params.eye.eye_used_str = 'LEFT';
elseif params.eye.eye_used == 1
    params.eye.eye_used_str = 'RIGHT';
elseif params.eye.eye_used == 2
    params.eye.eye_used_str = 'BINOCULAR';
end
    
% set fixation window

params.eye.fix_win_size = 'parafoveal';

% we use https://www.sr-research.com/visual-angle-calculator/ to calculate the visual angle
% the values are set using the distance of the screen and the screen size,
% then we take the "centered" output
% the values used below are half of the actual value returned by the script
% because the fixation window is set up using -fixWin and +fixWin
% see notes.md for more details.

% size of the fixation window to start the trial (2 degree visual angle)
% this is only used when flag.iseyetracker is true
params.eye.fixWinSizeSmallX = 49.28;
params.eye.fixWinSizeSmallY = 49.61;

% size of the fixation window during the trial (2 degree visual angle)
if params.ismeg
    % from the wiki
    % (https://wiki.cimec.unitn.it/tiki-index.php?page=VisualStimuliHwSetup)
    % the screen resolution is 1440x1080, screen ratio is 4:3 and whiteboard size is 51x38 cm
    
    if strcmp(params.eye.fix_win_size, 'foveal')
        params.eye.fixWinSizeLargeX = 49.28;
        params.eye.fixWinSizeLargeY = 49.61;
    elseif strcmp(params.eye.fix_win_size, 'parafoveal')
        params.eye.fixWinSizeLargeX = 111.66;
        params.eye.fixWinSizeLargeY = 110.93;
    end
    

else % gg pc
    if strcmp(params.eye.fix_win_size, 'foveal')
        params.eye.fixWinSizeLargeX = 145.07 / 2;
        params.eye.fixWinSizeLargeY = 145.07 / 2;
    elseif strcmp(params.eye.fix_win_size, 'parafoveal')
        params.eye.fixWinSizeLargeX = 145.07; % more or less
        params.eye.fixWinSizeLargeY = 145.07;
    end
end


 
