% % 
% Author : Dipesh Shrestha
% Date: Jan 19 2026
% % 
%% clean up
close all;
clear;

magic_cleanup = onCleanup(@ptb_cleanup);

 %% read trial structure  csv and convert to mat file
% % Read CSV into a table
% trials_df = readtable('trial_structure_input_right.csv');
% 
% % Save to .mat file
% save('trial_structure_input.mat', 'trials_df');

%% Setup Environment and Keyboard Input
setup_env;  % must create `params` as a struct

% Choose keyboard device ONCE and use it everywhere
% If you already store one in params, prefer that:
if isfield(params, 'kbdDeviceIndex')
    deviceIndex = params.kbdDeviceIndex;
else
    deviceIndex = [];
    params.kbdDeviceIndex = deviceIndex;  
end

queueCreated = false;


%% Collect participant input
if params.DEV_MODE
    params.subid = 'DEV';
    params.participant.name = 'DEV';
    params.participant.age = 99;
    params.lang = 2;
    params.ismeg = 0;
    params.iseye = 0;
    params.session = 1;
else
    params.subid = input('UID:  \ ');
    params.participant.name = input('Name: \','s');
    params.participant.age = input('Age: \ ');
    params.lang = input('language [1:ita | 2:eng] :  \  ');
    params.ismeg = input('MEG? [1: y | 0: n] :  \ '); % no meg ttls in training 
    params.iseye = input('Eyelink? [1:y | 0:n] :  \ ');
    params.session = input('session [1,2,3] :  \ ');
end
%% Setup Folders

if params.ismeg
    main_dir = 'C:\Users\auditory_vo\Desktop\mental_sim'; % setup for MEG exp 
elseif params.iseye
    eye_data_dir = 'C:\Users\Eyelink\Desktop\mental_sim'; % setup for eyelink exp
else
    main_dir = pwd; % use same folder if runningl locally
end

%% Load predefined matfiles for participants 

 
%% Load trial structure mat file 
load('trial_structure_input.mat','trials_df');
trials_df_shuff = create_trial_structure(trials_df);
 
%trials_df_shuff = trials_df_shuff(1:5, :);

trials_df_shuff = initialize_trials(trials_df_shuff);
params.participant.direction = trials_df.direction(1) * -1 ; 


%% --------- INITIALIZE PTB ---------------------
params = setup_psychtbx(params);


%% --------- INITIALIZE EYELINK AND TTLs ---------------------
if params.ismeg
    trigger_meg_init;
end 

if params.iseye
    eye = eye_init(params.ptb.window);
end 

%% Load trials using PTB

try
    %% read and save textures
    nCats = numel(params.categories);
    nImgs = 3;

    params.tex = cell(nCats, nImgs);
   
    for catIdx = 1:nCats
        for imgIdx = 1:nImgs
            imgPath = fullfile('animals', params.categories{catIdx}, sprintf('%d.png', imgIdx));
            if ~exist(imgPath, 'file')
                error('Missing image file: %s', imgPath);
            end
            img = imread(imgPath);
            params.tex{catIdx, imgIdx} = Screen('MakeTexture', params.ptb.window, img);
        end
    end


    %% keyboard queue (create/start for the SAME deviceIndex)
    KbQueueCreate(deviceIndex);
    queueCreated = true;
    KbQueueStart(deviceIndex);
    KbQueueFlush(deviceIndex);  % flush right after start
    
    KbName('UnifyKeyNames');
    spaceKey = KbName('Space');
    escKey   = KbName('ESCAPE');
    
    %% welcome screen
    create_welcome_screen(params);
    %%  setup eye tracking
    
    if params.iseye
        eye_calibration(eye)
    end 
    %%  setup MEG for TTLs
    
    %% load trials
    for i = 1:height(trials_df_shuff)
         
        [row,params] = load_trial(i, trials_df_shuff(i,:), params);
%         trials_df_shuff(i,:) = row;

        KbQueueFlush(deviceIndex);   % flush BEFORE waiting
        
        while params.BLOCK_TRIAL
            [pressed, firstPress] = KbQueueCheck(deviceIndex);

            if pressed
                if firstPress(escKey) > 0
                    error('UserAbort:ESC', 'Experiment aborted by user');
                elseif firstPress(spaceKey) > 0
                    break;
                end
            end

            WaitSecs(0.001);  % avoid 100% CPU
        end
        
        WaitSecs(0.001); %   avoid 100% CPU
        
        [pressed, firstPress] = KbQueueCheck(deviceIndex);

        if firstPress(escKey) > 0
            error('UserAbort:ESC', 'Experiment aborted by user');
        end 
    end

    %% goodbye screen
    create_goodbye_screen(params);
    %% normal cleanup
    if queueCreated
        KbQueueRelease(deviceIndex);
    end
    sca;
    
catch ME
    %% always cleanup
    if queueCreated
        try, KbQueueRelease(deviceIndex); end
    end
    try, sca; end

    if strcmp(ME.identifier, 'UserAbort:ESC')
        fprintf('Experiment terminated by user.\n');
        return;
    end

    rethrow(ME);
end
     