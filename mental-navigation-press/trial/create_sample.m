function [sampleOnset, sampleOffset, params] = create_sample(sampleDur, startId, targetCat,targetCatPos, targetId, params)
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
    xCenter = params.ptb.xCenter;
    yCenter = params.ptb.yCenter;
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
    
 
    spacingPx = params.LM_WIDTH_PX*2; 

    n = numel(params.trial.imgArrPos);
    params.trial.rects = cell(1, n);   % store destination params.trial.rects for all images

    %% --------------------------------------------------------------------
    % PTB handles and colors
    %% --------------------------------------------------------------------
    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;

    %% --------------------------------------------------------------------
    % Determine target image texture (category + image-within-category)
    %% --------------------------------------------------------------------
    params.trial.targetTex = params.tex{targetCat, targetCatPos};

    %% --------------------------------------------------------------------
    % Layout parameters
    %% --------------------------------------------------------------------

    % Target image is drawn below the row
    params.trial.targetRect = CenterRectOnPointd( ...
        [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
        xCenter, yCenter + params.TARGET_Y_PX ...
    );

    %% --------------------------------------------------------------------
    % Draw all start-array images
    %% --------------------------------------------------------------------
    Screen('FillRect', win, bg);
    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    for k = 1:n
        % Horizontal placement based on params.trial.imgArrPos
        xPos = params.ptb.xCenter + params.trial.imgArrPos(k);
        yPos = params.ptb.yCenter - params.START_Y_PX;

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
        dist = abs(params.trial.imgArrPos(k));
        % Draw image
        % choose a falloff radius (tune this)
        fadeRadius = spacingPx * 2;   % e.g., fully visible within ~2 slots

        % map distance -> alpha in [0..255]
        alpha01 = 1 - min(dist / fadeRadius, 1);   % 1 at center, 0 far away
        alpha   = round(255 * alpha01);
        
        alpha01 = alpha01.^2;   % or ^3 for sharper center emphasis
        alpha   = round(255 * alpha01);
        % draw with per-image opacity
 
        if params.participant.direction == 1 && params.trial.imgArrPos(k) <= 0 
            Screen('DrawTexture', win, curTex, [], params.trial.rects{k}, [], [], [], [255 255 255 alpha]);
        end
        
        if params.participant.direction == -1 && params.trial.imgArrPos(k) >= 0 
            Screen('DrawTexture', win, curTex, [], params.trial.rects{k}, [], [], [], [255 255 255 alpha]);
        end
    end

    %% --------------------------------------------------------------------
    % Draw target image and fixation dot
    %% --------------------------------------------------------------------
    Screen('DrawTexture', win, params.trial.targetTex, [], params.trial.targetRect);

    if ~isfield(params,'FIX_COLOR')
        params.FIX_COLOR = [0 255 0];
    end
    
    Screen('TextSize', win, params.FIX_SIZE_PX);
    fixY = params.ptb.yCenter - params.START_Y_PX;
    fixBounds = Screen('TextBounds', win, '+');
    fixRect   = CenterRectOnPointd(fixBounds, xCenter, fixY);
    Screen('DrawText', win, '+', fixRect(1), fixRect(2), params.FIX_COLOR);

    %% --------------------------------------------------------------------
    % Flip to show everything and record onset time
    %% --------------------------------------------------------------------
    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 
    sampleOnset = Screen('Flip', win, [], 1); 
    %% --------------------------------------------------------------------
    % Hold stimulus for the requested duration
    %% --------------------------------------------------------------------
    sampleOffset = WaitSecs('UntilTime', sampleOnset + sampleDur);
    %% --------------------------------------------------------------------
    % Clear screen and record offset time
    %% --------------------------------------------------------------------
    fprintf('sampleOffset at %g\n', sampleOffset);
end
