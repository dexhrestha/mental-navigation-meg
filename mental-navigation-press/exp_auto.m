% % 
% Author : Dipesh Shrestha
% Date: Jan 19 2026
% % 
%% clean up
close all;
clear;

%% Run if ptb not working
% currentFolder = pwd;
% 
% cd('/Applications/Psychtoolbox')
% SetupPsychtoolbox
% 
% cd(currentFolder)

%% Clean ptb
magic_cleanup = onCleanup(@ptb_cleanup);
addpath(genpath(pwd))

 %% read trial structure  csv and convert to mat file
% Read CSV into a table
INPUT_DIR = 'input';
OUTPUT_DIR = 'data';
trials_df = readtable(fullfile(INPUT_DIR,'trial_structure_input_left.csv'));

% Save to .mat file
save(fullfile(INPUT_DIR,'trial_structure_input.mat'), 'trials_df');

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
    prompt = { ...
    'UID:', ...
    'Name:', ...
    'Age:', ...
    'Language [1=ita | 2=eng]:', ...
    'MEG? [1=yes | 0=no]:', ...
    'Eyelink? [1=yes | 0=no]:', ...
    'Session [1,2,3]:' ...
    };

    dlgtitle = 'Participant Information';
    dims = [1 40];
    definput = {'DEV_006','DEV','20','2','0','0','1'};

    answer = inputdlg(prompt, dlgtitle, dims, definput);

    % Handle cancel
    if isempty(answer)
        error('Dialog cancelled by user.');
    end

    % Assign + type conversion
    params.subid             = answer{1};
    params.participant.name  = answer{2};
    params.participant.age   = str2double(answer{3});
    params.lang              = str2double(answer{4});
    params.ismeg             = str2double(answer{5}); % no meg ttls in training
    params.iseye             = str2double(answer{6});
    params.session           = str2double(answer{7});
end
t = datetime('now');
params.dateTime = datestr(t, 'yyyy_mm_dd_HH_MM'); 

%% build output directory: subjid/session_date
params.outDir = fullfile(OUTPUT_DIR,params.subid,num2str(params.session)); 
params.beh_out_dir = fullfile(params.outDir,'beh')
params.eye_out_dir = fullfile(params.outDir,'edf')
params.meg_out_dir = fullfile(params.outDir,'meg')

if ~isfolder(params.outDir)
    mkdir(params.beh_out_dir);
    mkdir(params.eye_out_dir);
    mkdir(params.meg_out_dir);
end

%% Load predefined matfiles for participants 
 
%% Load trial structure mat file 
load(fullfile(INPUT_DIR,'trial_structure_input.mat'),'trials_df');
trials_df_shuff = create_trial_structure(trials_df,params);
 
%trials_df_shuff = trials_df_shuff(1:5, :);

trials_df_shuff = initialize_trials(trials_df_shuff);
params.participant.direction = trials_df.direction(1) * -1 ; 


%% --------- INITIALIZE PTB ---------------------
setup_psychtbx;
%% --------- INITIALIZE EYELINK AND TTLs ---------------------
if params.ismeg
    fprintf('Initialize MEG sys');
    trigger_meg_init;
    params.triggers = create_meg_triggers();
    

end 
if params.add_bars
    params.Bars = create_meg_bars(params.ptb.window, params.SCREEN_WIDTH_PX, params.LM_HEIGHT_PX, [0 0 0]);
end
if params.iseye
    [eye,params] = eye_init(params);
end 

%% Load trials using PTB
try
    % read and save textures
    nCats = numel(params.categories);
    nImgs = params.catImages;

    params.tex = cell(nCats, nImgs);
   
    for catIdx = 1:nCats
        for imgIdx = 1:nImgs
            imgPath = fullfile('..','animals', params.categories{catIdx}, sprintf('%d.png', imgIdx));
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
    respKey = KbName('b');
    escKey   = KbName('ESCAPE');
    
    %% welcome screen
    create_welcome_screen(params);

    
    %% instruction screen
    create_instruction_screen(params);
    
    %% load trials
    params.blockId = 0;
    params.trialId = 0;
    params.runId = 0;
    % for each run 
    runs = unique(trials_df_shuff.run);
    
    for r = 1:numel(runs)
        
        run_id = runs(r);
        
        run_df = trials_df_shuff(trials_df_shuff.run == run_id, :);

        % experiment starts the run by pressing spacebar
        if params.ismeg
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
        end

        if params.runId ~= run_id % new run so do eye calibration and start recording 
            params.runId = run_id;

            if params.iseye 
                eye_calibration(eye)
            end 
        end 
        % load trials of a run
        for i = 1:height(run_df) 
            row =  run_df(i,:);

            if params.blockId ~= row.blockId(1)
                params.blockId = row.blockId(1);
            end 

            params.trialId = i;
            
            % send trigger at the start of the trial
            
            %  start recording ; file is made for each trial 
            if params.iseye
                edfFile = eye_startRecording(eye, params);
            end

            [row,params] = load_trial(row, params);

            run_df(i,:) = row;

            KbQueueFlush(deviceIndex);   % flush BEFORE waiting            
        end

        params.outFileName = sprintf('r%d', params.runId);
        
        %% save table to CSV
        csvFile = fullfile(params.outDir, sprintf('%s.csv',params.outFileName));
        fprintf('Writing to file %s',csvFile)
        writetable(run_df, csvFile);

        %% save everything to MAT file
        matFile = fullfile(params.outDir, sprintf('%s.mat',params.outFileName));
        fprintf('Writing to file %s',matFile)
        save(matFile, 'run_df', 'params');
        
        if params.ismeg            
            trigger_meg_send(params.triggers.BRK_START,0.005);
        end
        
        create_break_screen(params);

        if params.ismeg
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
        fprintf('Experiment terminated by user.\n');
        return;
    end

    rethrow(ME);
end
     
sca;