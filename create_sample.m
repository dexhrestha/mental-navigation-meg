function [sampleOnset, sampleOffset, params] = create_sample(sampleDur, startCat,startCatPos, startId, targetCat,targetCatPos, targetId, params)
% CREATE_SAMPLE
% Displays a row of images centered around the start image, plus a target image
% and a fixation dot. All stimuli are shown for sampleDur milliseconds.
%
% Inputs:
%   sampleDur  - duration in milliseconds
%   startCat   - category index of start image (not used directly here)
%   startId    - global image ID (1..18) used to center the array
%   targetCat  - category index of target image
%   targetId   - global image ID of target
%   params     - struct containing window, textures, colors, layout params
%
% Outputs:
%   sampleOnset  - timestamp of stimulus onset (Screen('Flip'))
%   sampleOffset - timestamp of stimulus offset

    %% Convert duration to seconds
    sampleDur = sampleDur / 1000;  % ms -> s
     %% --------------------------------------------------------------------
    % Build ordered image ID array and shift so startId is at the center
    %% --------------------------------------------------------------------
    imgArr = 1:18;
    N = numel(imgArr);

    % NOTE: This puts the center at index 10 (since N=18 has no true center)
    centerIdx = ceil(N/2) + 1;

    % Find current position of the start image ID
    currIdx = find(imgArr == startId);

    % Circularly shift so startId appears at the center
    shiftAmount = centerIdx - currIdx;
    params.trial.imgArrShifted = circshift(imgArr, shiftAmount);

    %% --------------------------------------------------------------------
    % Compute X positions relative to screen center
    % Values are symmetric around 0 and spaced by 100 px
    %% --------------------------------------------------------------------
    params.trial.imgArrPos = ((1:N) - centerIdx) * (params.LM_WIDTH_PX +   params.ILD_PX);

    n = numel(params.trial.imgArrPos);
    params.trial.rects = cell(1, n);   % store destination params.trial.rects for all images

    %% --------------------------------------------------------------------
    % PTB handles and colors
    %% --------------------------------------------------------------------
    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;
    red = [255 0 0];

    %% --------------------------------------------------------------------
    % Determine target image texture (category + image-within-category)
    %% --------------------------------------------------------------------
%     targetCatImgId = mod(targetId - 1, 3) + 1;

    params.trial.targetTex = params.tex{targetCat, targetCatPos};

    %% --------------------------------------------------------------------
    % Layout parameters
    %% --------------------------------------------------------------------

    [xCenter, yCenter] = RectCenter(Screen('Rect', win));

    % Target image is drawn below the row
    params.trial.targetRect = CenterRectOnPointd( ...
        [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
        xCenter, yCenter + params.TARGET_Y_PX ...
    );

    %% --------------------------------------------------------------------
    % Draw all start-array images
    %% --------------------------------------------------------------------
    Screen('FillRect', win, bg);

    for k = 1:n
        % Horizontal placement based on params.trial.imgArrPos
        xPos = xCenter + params.trial.imgArrPos(k);
        yPos = yCenter - params.START_Y_PX;

        % Destination rect for this image
        params.trial.rects{k} = CenterRectOnPointd( ...
            [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
            xPos, yPos ...
        );

        % Global image ID after shifting
        currImgId = params.trial.imgArrShifted(k);

        % Image index within category (1..3)
        currCatImgId = mod(currImgId - 1, 3) + 1;

        % Category index (1..6), grouped in blocks of 3 images
        currCatId = mod(floor((currImgId - 1) / 3), 6) + 1;

        % Retrieve preloaded texture
        curTex = params.tex{currCatId, currCatImgId};

        % Draw image
        Screen('DrawTexture', win, curTex, [], params.trial.rects{k});
    end

    %% --------------------------------------------------------------------
    % Draw target image and fixation dot
    %% --------------------------------------------------------------------
    Screen('DrawTexture', win, params.trial.targetTex, [], params.trial.targetRect);

    params.trial.dotRect = CenterRectOnPointd([0 0 params.FIX_SIZE_PX params.FIX_SIZE_PX], xCenter, yCenter);
    Screen('FillOval', win, red, params.trial.dotRect);

    %% --------------------------------------------------------------------
    % Flip to show everything and record onset time
    %% --------------------------------------------------------------------
    sampleOnset = Screen('Flip', win, [], 1);  % dontclear=1
    fprintf('sampleOnset at %g\n', sampleOnset);
    fprintf('Wait for %g s\n', sampleDur);

    %% --------------------------------------------------------------------
    % Hold stimulus for the requested duration
    %% --------------------------------------------------------------------
    sampleOffset = WaitSecs('UntilTime', sampleOnset + sampleDur);

    %% --------------------------------------------------------------------
    % Clear screen and record offset time
    %% --------------------------------------------------------------------
%     Screen('FillRect', win, bg);
%      = Screen('Flip', win);
    fprintf('sampleOffset at %g\n', sampleOffset);
 
end
