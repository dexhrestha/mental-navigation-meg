function [speedCueOnset,speedCueOffset] = create_speed_cue(speed,params)
    speedCueDur = params.SPEED_CUE_DUR;
    
    win   = params.window;
    bg  = params.BG_COLOR;
    red = [255 0 0];

    color = params.TEXT_COLOR;        
%     Draw speed text
    DrawFormattedText( ...
        win, ...
        sprintf('Speed: %g', speed), ...
        'center', 'center', ...
        color ...
    );

    % Flip to screen and get onset timestamp
    speedCueOnset = Screen('Flip', win);
    

%% Move images for 2 complete loops
    imgArr = 1:params.N_IMAGES;
    N = numel(imgArr);
    startId = ceil(N/2) + 1;
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
    params.trial.imgArrPos = ((1:N) - centerIdx) * (50 + 50);
    
    [xCenter, yCenter] = RectCenter(Screen('Rect', win));
    
    n = numel(params.trial.imgArrPos);

    % --- motion control: EXACTLY 100 px in 1 second ---
    speedPxPerSec = 100;
    ifi = Screen('GetFlipInterval', win);
    dxPerFrame = speedPxPerSec * ifi;

    % Base slot positions and spacing
    basePos = params.trial.imgArrPos(:)';      % row vector
    baseSorted = sort(basePos);
    spacingPx = median(diff(baseSorted));
    if ~isfinite(spacingPx) || spacingPx <= 0
        spacingPx = 100; % fallback
    end
    
    offsetPx = 0;
    movementDur = params.N_IMAGES/speed*params.SPEED_CUE_LOOPS;
    
    vbl = speedCueOnset;
    endT = speedCueOnset+movementDur;
    while true
        if vbl >= endT
            break;
        end

        % --- update smooth offset ---
        offsetPx = offsetPx + dxPerFrame * params.participant.direction;

        % --- rotate IDs when passing >= 1 slot ---
        stepCount = fix(offsetPx / spacingPx);  % trunc toward 0 (works for +/-)
        if stepCount ~= 0
            offsetPx = offsetPx - stepCount * spacingPx;

            % If direction feels reversed, flip sign here:
            params.trial.imgArrShifted = circshift(params.trial.imgArrShifted, stepCount);
            % params.trial.imgArrShifted = circshift(params.trial.imgArrShifted, -stepCount);
        end

        currPos = basePos + offsetPx;

        % --- draw frame ---
        Screen('FillRect', win, bg);

        for k = 1:n
            xPos = xCenter + currPos(k);
            yPos = yCenter - params.START_Y_PX;

            dstRect = CenterRectOnPointd([0 0 params.LM_WIDTH params.LM_HEIGHT], xPos, yPos);

            currImgId = params.trial.imgArrShifted(k);
            currCatImgId = mod(currImgId - 1, 3) + 1;
            currCatId    = mod(floor((currImgId - 1) / 3), 6) + 1;

            curTex = params.tex{currCatId, currCatImgId};
            Screen('DrawTexture', win, curTex, [], dstRect);
        end
        
        dotRect = CenterRectOnPointd([0 0 params.FIX_SIZE_PX params.FIX_SIZE_PX], xCenter, yCenter);
        Screen('FillOval', win, red, dotRect);
        % --- synced flip ---
        vbl = Screen('Flip', win, vbl + 0.5 * ifi);

    end


%% 
%     fprintf('speedCueOnset %g at %g  \n', speed,speedCueOnset);
%     fprintf('Wait for %g seconds\n', speedCueDur);
    [speedCueOffset] = WaitSecs(speedCueDur);
    fprintf('speedCueOffset %g\n',speedCueOffset)
end
