% % 
% Author : Dipesh Shrestha
% Date: Jan 19 2026
% % 
%% clean up
close all;
clear;

magic_cleanup = onCleanup(@ptb_cleanup);

 %% read trial structure  csv and convert to mat file
% Read CSV into a table
trials_df = readtable('trial_structure_input_right.csv');

% Save to .mat file
save('trial_structure_input.mat', 'trials_df');

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
    params.ismeg = 1;
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
    definput = {'001','DEV','99','2','0','0','1'};

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
load('trial_structure_input.mat','trials_df');
trials_df_shuff = create_trial_structure(trials_df,params);
 
%trials_df_shuff = trials_df_shuff(1:5, :);

trials_df_shuff = initialize_trials(trials_df_shuff);
params.participant.direction = trials_df.direction(1) * -1 ; 


%% --------- INITIALIZE PTB ---------------------
params = setup_psychtbx(params);


%% --------- INITIALIZE EYELINK AND TTLs ---------------------
% if params.ismeg
%     trigger_meg_init;
% end 

if params.iseye
    eye = eye_init(params);
end 

%% Load trials using PTB

try
    %% read and save textures
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
    spaceKey = KbName('Space');
    escKey   = KbName('ESCAPE');
    
    %% welcome screen
    create_welcome_screen(params);

    
    %% load trials
    params.blockId = 0;
    params.trialId = 0;
    params.runId = 0;
    % for each run 
    runs = unique(trials_df_shuff.run);
    
    for r = 1:numel(runs)
        
        
        % call break screen 
        
        run_id = runs(r);
        
        run_df = trials_df_shuff(trials_df_shuff.run == run_id, :);
        run_df = run_df(1:3, :);

        % kb wait 
        % save data manually 
        
        % start recording eye 
        % send meg trigger
        
        % experiment starts the run by pressing spacebar
        if params.ismeg
            while true
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
        end

        WaitSecs(0.001); %   avoid 100% CPU

        [pressed, firstPress] = KbQueueCheck(deviceIndex);
        
        if firstPress(escKey) > 0
            error('UserAbort:ESC', 'Experiment aborted by user');
        end 
        if params.runId ~= run_id % new run so do eye calibration and start recording 
            params.runId = run_id;

            if params.iseye
                eye_calibration(eye)
            end 

            % calibrate eye tracker 
            if params.iseye
               eye_calibration(eye)
            end 
            %  start recording ; file is made for each run 
            if params.iseye
                % check Fixation, if subject is fixating properly, begin experiment, else halt
                % the waiting loop is in the function itself
                eye_beginTrialFixation(eye, params);
                % open file and start recording
                edfFile = eye_startRecording(eye, params);
            end
        end 
        for i = 1:height(run_df) 
            row =  run_df(i,:);

            if params.blockId ~= row.blockId(1)
                params.blockId = row.blockId(1);
            end 

            params.trialId = i;

            [row,params] = load_trial(row, params);
            %% record data 

            run_df(i,:) = row;

            KbQueueFlush(deviceIndex);   % flush BEFORE waiting            
        end

        %% build output directory: subjid/session_date
        outDir = params.subid;
        outFileName = sprintf('s%d_r%d', params.session, params.runId);

        if ~isfolder(outDir)
            mkdir(outDir);
        end

        %% save table to CSV
        csvFile = fullfile(outDir, sprintf('%s.csv',outFileName));
        writetable(run_df, csvFile);

        %% save everything to MAT file
        matFile = fullfile(outDir, sprintf('%s.mat',outFileName));
        save(matFile, 'run_df', 'params');
        create_break_screen(params);

        if params.iseye
            eye_stopRecording(params.runId,params.blockId);
            edfFile = fullfile(outDir, sprintf('%s.edf',outFileName));
            eye_saveEDF(params,edfFile);
        end


        if params.ismeg
            fprintf('send_stop_trigger_meg;');
            %send_stop_trigger_meg;
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

% welcome 
% instructions 

% for each run 
% kb wait ( manually save meg data; so experimenter can start the experiment  )
 % another script ( load trials in run )
     % for each trial in the run
     % show trials 
     %end trials
     
    % save the data for run
    % show a break screen (  " this is a break ')
    % send trigger for eye and Meg  ( start trigger)
    % wait (~ 1min )
    % send trigger  ( stop trigger )
   % end run 