function [sampleOnset, sampleOffset,sampleDa, params] = create_sample(sampleDur, startId, targetCat,targetCatPos, targetId, params)
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

    % Use one explicit centre slot. For N = 18 there is no mathematically
    % perfect middle item, so this chooses slot 10. The important point is
    % that the same slot is used both for circshift and for imgArrPos = 0.
    centerIdx = ceil(N / 2) + 1;

    % Find current position of the start image ID.
    currIdx = find(imgArr == startId, 1);

    if isempty(currIdx)
        error('create_sample:badStartId', ...
            'startId %d was not found in imgArr.', startId);
    end

    % Circularly shift so startId appears at centerIdx.
    shiftAmount = centerIdx - currIdx;
    params.trial(params.trialId).imgArrShifted = circshift(imgArr, shiftAmount);

    % Verify where startId ended up after shifting. This index is then used
    % to define the x-position array, guaranteeing that startId is exactly
    % at xCenter / position 0.
    startCenterIdx = find(params.trial(params.trialId).imgArrShifted == startId, 1);

    if isempty(startCenterIdx)
        error('create_sample:shiftFailed', ...
            'startId %d was not found after circshift.', startId);
    end
    
    %% --------------------------------------------------------------------
    % Compute X positions relative to screen center.
    % The shifted startId is forced to position 0.
    %% --------------------------------------------------------------------
    spacingPx = params.LM_WIDTH_PX + params.ILD_PX;
    params.trial(params.trialId).imgArrPos = ((1:N) - startCenterIdx) * spacingPx;

    % Store diagnostics for checking alignment.
    params.trial(params.trialId).sampleStartIdx = startCenterIdx;
    params.trial(params.trialId).sampleStartPosPx = ...
        params.trial(params.trialId).imgArrPos(startCenterIdx);

    n = numel(params.trial(params.trialId).imgArrPos);
    params.trial(params.trialId).rects = cell(1, n);   % store destination params.trial(params.trialId).rects for all images

    %% --------------------------------------------------------------------
    % PTB handles and colors
    %% --------------------------------------------------------------------
    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;

    %% --------------------------------------------------------------------
    % Determine target image texture (category + image-within-category)
    %% --------------------------------------------------------------------
    params.trial(params.trialId).targetTex = params.tex{targetCat, targetCatPos};

    %% --------------------------------------------------------------------
    % Layout parameters
    %% --------------------------------------------------------------------

    % Target image is drawn below the row
    params.trial(params.trialId).targetRect = CenterRectOnPointd( ...
        [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
        xCenter, yCenter + params.TARGET_Y_PX ...
    );

    %% --------------------------------------------------------------------
    % Draw all start-array images
    %% --------------------------------------------------------------------
    Screen('FillRect', win, bg);
    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    yPos = params.ptb.yCenter - params.START_Y_PX;
    
    params.star = drawHyperspaceStarfield(params,0);
    nCats = size(params.tex, 1);
    nCatImgs = size(params.tex, 2);
    
    for k = 1:n
        % Horizontal placement based on params.trial(params.trialId).imgArrPos
        if params.CENTRAL
            xPos = params.ptb.xCenter;
        else
            xPos = params.ptb.xCenter + params.trial(params.trialId).imgArrPos(k);
        end
        

        % Destination rect for this image
        params.trial(params.trialId).rects{k} = CenterRectOnPointd( ...
            [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
            xPos, yPos ...
        );

        % Global image ID after shifting
        currImgId = params.trial(params.trialId).imgArrShifted(k);

        % Image index within category (1..3)
        currCatImgId = mod(currImgId - 1, nCatImgs) + 1;

        % Category index (1..6), grouped in blocks of 3 images
        currCatId = mod(floor((currImgId - 1) / nCatImgs), nCats) + 1;

        % Retrieve preloaded texture
        curTex = params.tex{currCatId, currCatImgId};
        dist = abs(params.trial(params.trialId).imgArrPos(k));
        % Draw image
        % choose a falloff radius (tune this)
        fadeRadius = spacingPx ;   % e.g., fully visible within ~2 slots

        % map distance -> alpha in [0..255]
        alpha01 = 1 - min(dist / fadeRadius, 1);   % 1 at center, 0 far away
        alpha   = round(255 * alpha01);
        
        alpha01 = alpha01.^8;   % or ^3 for sharper center emphasis
        alpha   = round(255 * alpha01);
        
        % draw with per-image opacity
        % left
        if params.participant.direction == 1 && params.trial(params.trialId).imgArrPos(k) <= 0 
            Screen('DrawTexture', win, curTex, [], params.trial(params.trialId).rects{k}, [], [], [], [255 255 255 alpha]);
        end
        % right 
        if params.participant.direction == -1 && params.trial(params.trialId).imgArrPos(k) >= 0 
            Screen('DrawTexture', win, curTex, [], params.trial(params.trialId).rects{k}, [], [], [], [255 255 255 alpha]);
        end
    end

    %% --------------------------------------------------------------------
    % Draw target image and fixation dot
    %% --------------------------------------------------------------------
    
    
    Screen('DrawTexture', win, params.trial(params.trialId).targetTex, [], params.trial(params.trialId).targetRect);

    if ~isfield(params,'FIX_COLOR')
        params.FIX_COLOR = [0 255 0];
    end
    
    Screen('TextSize', win, params.FIX_SIZE_PX);
    fixY = params.ptb.yCenter - params.START_Y_PX;
    fixBounds = Screen('TextBounds', win, '+');
    fixRect   = CenterRectOnPointd(fixBounds, xCenter, fixY);
    Screen('DrawText', win, '+', fixRect(1), fixRect(2), params.FIX_COLOR);
    
    dstRect  = CenterRectOnPointd( ...
            [0 0 params.LM_WIDTH_PX * 1.25 params.LM_HEIGHT_PX*1.25], ...
            xCenter, fixY ...
        );
    
    drawImgHUD(params);


    %% --------------------------------------------------------------------
    % Flip to show everything and record onset time
    %% --------------------------------------------------------------------
    drawHUD(params);
    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 
    
    sampleOnset = Screen('Flip', win, [], 1); 
    %% --------------------------------------------------------------------
    % Hold stimulus for the requested duration
    %% --------------------------------------------------------------------
    KbName('UnifyKeyNames');

    params.trial(params.trialId).startPressed = 0;
    sampleEnd = sampleOnset + sampleDur;

    while GetSecs < sampleEnd
        pressed = check_response(params,params.START_KEY,1);

        if ~params.trial(params.trialId).startPressed && pressed ~= 0
            params.trial(params.trialId).startPressed = pressed;
        elseif params.trial(params.trialId).startPressed && pressed == 0
            params.trial(params.trialId).startPressed = pressed;
            break
        end

        % [keyIsDown, ~, keyCode] = KbCheck(params.kbdDeviceIndex);
        % if keyIsDown && keyCode(escKey)
        %     sca;
        %     error('UserAbort:ESC', 'Experiment aborted by user');
        % end
        % if ~keyCode(respKey)
        %     params.trial(params.trialId).sampleHoldBroken = true;
        %     break;
        % end
        WaitSecs(0.001);
    end

    sampleOffset = GetSecs;
    %% --------------------------------------------------------------------
    % Clear screen and record offset time
    %% --------------------------------------------------------------------
    % fprintf('sampleOffset at %g\n', sampleOffset);
    sampleDa = sampleOffset - sampleOnset;
end
