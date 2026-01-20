close all;
clear;

load('trial_structure_input.mat','trials_df');
trials_df_shuff = create_trial_structure(trials_df);
 
% trials_df_shuff = trials_df_shuff(1:5, :);

trials_df_shuff = initialize_trials(trials_df_shuff);

setup_env;  % must cre    ate `params`

% Choose keyboard device ONCE and use it everywhere
% If you already store one in params, prefer that:
if isfield(params, 'kbdDeviceIndex')
    deviceIndex = params.kbdDeviceIndex;
else
    deviceIndex = [];
    params.kbdDeviceIndex = deviceIndex;  
end

queueCreated = false;

try
    %% setup screen and textures
    params = setup_psychtbx(params);
    
    % read and save textures
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
            params.tex{catIdx, imgIdx} = Screen('MakeTexture', params.window, img);
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
     