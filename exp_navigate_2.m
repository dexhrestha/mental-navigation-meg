% % 
% Author : Dipesh Shrestha
% Date: Jan 19 2026
% % 
%% clean up
close all;
clear;

%% Run if ptb not working
% currentFolder = pwd;
% % 
% cd('/Applications/toolbox/Psychtoolbox')
% SetupPsychtoolbox
% % 
% cd(currentFolder)
%% Clean ptb
magic_cleanup = onCleanup(@ptb_cleanup);

folders = {'input','instructions','trial','utils','animals','assets','stim'};
base_dir = pwd;

for i = 1:numel(folders)
    addpath(genpath(fullfile(base_dir,folders{i})));
end
%% Setup Environment and Keyboard Input
setup_env;  % must create `params` as a struct

 %% read trial structure  csv and convert to mat file
% Read CSV into a table
INPUT_DIR = 'input';
INPUT_DIR = fullfile(INPUT_DIR,params.COHORT_DIR);

OUTPUT_DIR = 'data';
%% Choose keyboard device ONCE and use it everywhere
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
    params.subid = 1;
    params.participant.name = '1';
    params.participant.age = 99;
    params.lang = 1;
    params.is_meg = 0;
    params.is_eye = 0;
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
    definput = {'1','1','20','2','0','0','1','1'};

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
    params.is_meg             = str2double(answer{5}); % no meg ttls in training
    params.is_eye             = str2double(answer{6});
    params.session           = str2double(answer{7});
    params.add_bars          = str2double(answer{8});
    
end
t = data_time('now');
params.data_time = datestr(t, 'yyyy_mm_dd_HH_MM'); 
%% read input file and convert it to mat for matlab to read
% input path strucutre : 'subj-<label>/ses-<label>/input'
pattern = sprintf('subj-%02d/ses-%02d/input.csv', params.subid,params.session);
% change to sub and remove above line later
% pattern = sprintf('sub-%02d/ses-%02d/input.csv', params.subid,params.session);

% List matching files
files = dir(fullfile(INPUT_DIR, pattern));

% Sanity check
if isempty(files)
    error('No trial_structure_input file found for subject %d.', params.subid);
elseif numel(files) > 1
    error('Multiple trial_structure_input files found for subject %d.', params.subid);
end

% Full path to the file
filePath = fullfile(files(1).folder, files(1).name);

% Original name
csvName = files(1).name;

% Split into parts
[filepath, name, ~] = fileparts(csvName);

% Replace extension with .mat
matName = [name, '.mat'];

% Read table
trials_df = readtable(filePath);
% Save to .mat file
input_mat_path = fullfile(files(1).folder,matName);
save(input_mat_path, 'trials_df');
%% build output directory: subjid/session_date
params.outDir = fullfile(OUTPUT_DIR,num2str(params.subid),num2str(params.session),params.data_time); 
params.beh_out_dir = fullfile(params.outDir,'beh');
params.eye_out_dir = fullfile(params.outDir,'edf');
params.meg_out_dir = fullfile(params.outDir,'meg');

if ~isfolder(params.outDir)
    mkdir(params.beh_out_dir);
    mkdir(params.eye_out_dir);
    mkdir(params.meg_out_dir);
end

%% Load trial structure mat file 
load(input_mat_path,'trials_df');

 

trials_df = initialize_trials(trials_df);
params.participant.direction = trials_df.direction(1);
%% --------- INITIALIZE PTB ---------------------
setup_psychtbx;
%% --------- INITIALIZE EYELINK AND TTLs ---------------------

    
if params.is_meg
    disp('meg flag in');
    fprintf('Initialize MEG sys');
    trigger_meg_init;
    params.triggers = create_meg_triggers();
    [params.buttons, params.suppressor] = LV_init_response; 
    disp('meg flag out');

end 
if params.add_bars
    params.Bars = create_meg_bars(params.ptb.window, params.SCREEN_WIDTH_PX, params.LM_HEIGHT_PX, [0 0 0]);
end
if params.is_eye
    [eye,params] = eye_init(params);
end 

%% Load trials using PTB
try
    % read and save textures
    

    params.tex = cell(params.n_categories, params.n_cat_images);
   
    for catIdx = 1:params.n_categories
        for imgIdx = 1:params.n_cat_images
            imgPath = fullfile('stim',params.COHORT_DIR, ...
                sprintf('sequence_%02d', params.subid), ...
                sprintf('pos_%d_img%d.png', catIdx, imgIdx));  

            if ~exist(imgPath, 'file')
                error('Missing image file: %s', imgPath);
            end
            img = imread(imgPath);
            params.tex{catIdx, imgIdx} = Screen('MakeTexture', params.ptb.window, img);
        end
    end


    %% keyboard queue (create/start for th
    %   e SAME deviceIndex)
    KbQueueCreate(deviceIndex);
    queueCreated = true;
    KbQueueStart(deviceIndex);
    KbQueueFlush(deviceIndex);  % flush right after start
    
    KbName('UnifyKeyNames');
    respKey = KbName('b');
    escKey   = KbName('ESCAPE');
    %% SETUP MEG BUTTONS
    % Assuming box 1 is rd(1)/blu(8) & box 2 is grn(4)/ylw(2)
    % Add this to dialog box
    %RT dominant = 1; LT dominant = 2;
    params.dominant = 1; % or 2 
     
    if params.dominant == 1
        params.START_KEY = 8;    
        params.LT_KEY = 2;
        params.RT_KEY = 4;
    
    elseif params.dominant == 2
        params.START_KEY = 4;
        params.LT_KEY = 8;
        params.RT_KEY = 1;
    
    else
        sca;
        error('UserAbort:Esc', 'params.dominant Value should be 1 or 2');
    end
    
    if ~params.is_meg
        params.START_KEY = KbName('b');
        params.LT_KEY = KbName('LeftArrow');
        params.RT_KEY = KbName('RightArrow');
        
    end

    %% Welcome screen
    create_welcome_screen(params);
    
    
    %% Instruction screen
    params.EXP_MODE = 'navigate';
    create_instruction_screen(params);
   
    %% setup stars
    params = setup_stars(params);
    params = setup_HUD(params);
    %% load trials
    params.blockId = 0;
    params.trialId = 0;
    params.runId = 0;
    % for each run bb
    runs = unique(trials_df.run);
    %% load each run and save data after each run
    for r = 1: numel(runs)
        run_id = runs(r);
        
        run_df = trials_df(trials_df.run == run_id, :);

        % experiment starts the run by pressing spacebar
        if params.is_meg
            while true
                [pressed, firstPress] = KbQueueCheck(deviceIndex);

                if pressed
                    if firstPress(escKey) > 0
                        error('UserAbort:ESC', 'Experiment aborted by user');
                    elseif firstPress(respKey) > 0
                        break;
                    end
                end

                WaitSecs(0.001);  % avoid 100% CPU
            end
        
        else
            pressed = check_response(params,params.START_KEY);
        end
        if params.runId ~= run_id 
            params.runId = run_id;
        end 
        % load trials of a run
        params.outFileName = sprintf('r%d', params.runId);
        % new run so do eye calibration and start recording 
        
        if params.is_eye            
            eye_calibration(eye,params)
        end
        
        for i = 1 :  height(run_df) 
            row =  run_df(i,:);

            if params.blockId ~= row.block(1)
                params.blockId = row.block(1);
            end 

            params.trialId = row.trial(1); 

            [row,params] = load_trial(row, params);

            run_df(i,:) = row;

            KbQueueFlush(deviceIndex);   % flush BEFORE waiting            
        end

        %% save table to CSV
        csvFile = fullfile(params.beh_out_dir , sprintf('%s.csv',params.outFileName));
        fprintf('Writing to file %s \n',csvFile)
        writetable(run_df, csvFile);

        %% save everything to MAT file
        matFile = fullfile(params.beh_out_dir , sprintf('%s.mat',params.outFileName));
        fprintf('Writing to file %s \n',matFile)
        save(matFile, 'run_df', 'params');
        
        if params.is_meg            
            trigger_meg_send(params.triggers.BRK_START,0.005);
        end
        
        if run_id<6
            create_break_screen(params);
        end 

        if params.is_meg
            trigger_meg_send(params.triggers.BRK_END,0.005); 
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
         %% save everything to MAT file
        if isfield(params,'outFileName')
            matFile = fullfile(params.beh_out_dir , sprintf('%s.mat',params.outFileName));
            fprintf('Writing to file %s \n',matFile)
            save(matFile, 'run_df', 'params');
        else
            fprintf('No data to save .\n');
        end
        
        
        fprintf('Experiment terminated by user.\n');
        return;
    end

    rethrow(ME);
end
     
sca;