% % 
% Author : Dipesh Shrestha
% Date: Jan 19 2026
% % 
%% clean up
close all;
clear;

magic_cleanup = onCleanup(@ptb_cleanup);

%% Clean ptb
magic_cleanup = onCleanup(@ptb_cleanup);

folders = {'input','instructions','trial','utils','animals'};
base_dir = pwd;

for i = 1:numel(folders)
    addpath(genpath(fullfile(base_dir,folders{i})));
end

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
    params.subid = 0;
    params.participant.name = '0';
    params.participant.age = 99;
    params.lang = 2;
    params.ismeg = 0;
    params.iseye = 0;
    params.session = 1;
    params.add_bars = 1;
else
    prompt = { ...
    'UID:', ...
    'Name:', ...
    'Age:', ...
    'Language [1=ita | 2=eng]:', ...
    'MEG? [1=yes | 0=no]:', ...
    'Eyelink? [1=yes | 0=no]:', ...
    'Session [1,2,3]:' ...
    'Bars [1=yes | 0=no]:'
    };

    dlgtitle = 'Participant Information';
    dims = [1 40];
    definput = {'0','Pilot0','20','2','0','0','1','1'};

    answer = inputdlg(prompt, dlgtitle, dims, definput);

    % Handle cancel
    if isempty(answer)
        error('Dialog cancelled by user.');
    end

    % Assign + type conversion
    params.subid             = str2double(answer{1});
    params.participant.name  = answer{2};
    params.participant.age   = str2double(answer{3});
    params.lang              = str2double(answer{4});
    params.ismeg             = str2double(answer{5}); % no meg ttls in training
    params.iseye             = str2double(answer{6});
    params.session           = str2double(answer{7});
    params.add_bars          = str2double(answer{8});
    
end
t = datetime('now');
params.dateTime = datestr(t, 'yyyy_mm_dd_HH_MM'); 

%% Setup Folders

if params.ismeg
    main_dir = 'C:\Users\auditory_vo\Desktop\mental_sim'; % setup for MEG exp 
elseif params.iseye
    eye_data_dir = 'C:\Users\EYE\Desktop\mental_sim'; % setup for eyelink exp
else
    main_dir = pwd; % use same folder if runningl locally
end

%% Load predefined matfiles for participants 

 
%% Load trial structure mat file 
% load('trial_structure_input.mat','trials_df');
% trials_df_shuff = create_trial_structure(trials_df,params);
% 
% trials_df_shuff = trials_df_shuff(1:5, :);
% 
% trials_df_shuff = initialize_trials(trials_df_shuff);
% params.participant.direction = trials_df.direction(1) * -1 ; 

%% --------- INITIALIZE PTB ---------------------
setup_psychtbx;


%% --------- INITIALIZE EYELINK AND TTLs ---------------------
% if params.ismeg
%     trigger_meg_init;
% end 
if params.add_bars
    params.Bars = create_meg_bars(params.ptb.window, params.SCREEN_WIDTH_PX, params.LM_HEIGHT_PX, [0 0 0]);
end
if params.iseye
    eye = eye_init(params);
end 


try
    %% read and save textures
    nCats = numel(params.categories);
    nImgs = params.catImages;

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
    spaceKey = KbName('b');
    escKey   = KbName('ESCAPE');
    
    %% welcome screenb
    create_welcome_screen(params);
    
    %% instruction screen
    params.EXP_MODE = 'explore';
    create_instruction_screen(params);

    %% Load images using PTB
    params = create_img_seq(250,1,params);
    params = create_navigation(1,params);
    
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
     
sca;