function [speedCueOnset,speedCueOffset] = create_speed_cue(speed,params)
    speedCueDur = params.SPEED_CUE_DUR;
    
    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;
    red = [255 0 0];
    
    color = params.TEXT_COLOR;        
    if speed == 1.2
        speed_text = 'SLOW';
    else 
        speed_text = 'FAST';
    end
    
    
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
    params.trial.imgArrPos = ((1:N) - centerIdx) * (params.LM_WIDTH_PX +   params.ILD_PX);
    
    [xCenter, yCenter] = RectCenter(Screen('Rect', win));
    
    n = numel(params.trial.imgArrPos);
    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    
    % --- motion control: EXACTLY 100 px in 1 second ---
    speedPxPerSec = speed * (params.LM_WIDTH_PX + params.ILD_PX);
    ifi = Screen('GetFlipInterval', win);
    dxPerFrame = speedPxPerSec * ifi;

    % Base slot positions and spacing
    basePos = params.trial.imgArrPos(:)';      % row vector
    baseSorted = sort(basePos);
    spacingPx = median(diff(baseSorted));
    if ~isfinite(spacingPx) || spacingPx <= 0
        spacingPx = params.LM_WIDTH_PX*2; % fallback
    end
    
    offsetPx = 0;
    movementDur = params.N_IMAGES/speed*params.SPEED_CUE_LOOPS;
    Screen('TextSize', win, round(double(params.SPEED_TEXT_PX)));
    % Draw speed text
     DrawFormattedText( ...
            win, ...
            sprintf(speed_text), ...
            'center', yCenter - params.SPEED_CUE_OFFSET_PX, ...
            color ...
        );
    
     DrawFormattedText( ...
        win, ...
        sprintf('ADD MORE INSTRUCTIONS HERE'), ...
        'center', yCenter + params.SPEED_CUE_OFFSET_PX, ...
        color ...
    );


    % Flip to screen and get onset timestamp
    speedCueOnset = Screen('Flip', win);
    
    
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

            dstRect = CenterRectOnPointd([0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], xPos, yPos);

            currImgId = params.trial.imgArrShifted(k);
            currCatImgId = mod(currImgId - 1, 3) + 1;
            currCatId    = mod(floor((currImgId - 1) / 3), 6) + 1;

            curTex = params.tex{currCatId, currCatImgId};
            
            dist = abs(currPos(k));   % because currPos is relative to center already

            % choose a falloff radius (tune this)
            fadeRadius = spacingPx * 2;   % e.g., fully visible within ~2 slots

            % map distance -> alpha in [0..255]
            alpha01 = 1 - min(dist / fadeRadius, 1);   % 1 at center, 0 far away
%                 alpha   = round(255 * alpha01);

            alpha01 = alpha01.^2;   % or ^3 for sharper center emphasis
            alpha   = round(255 * alpha01);

            % draw with per-image opacity
            Screen('DrawTexture', win, curTex, [], dstRect, [], [], [], [255 255 255 alpha]);
%             Screen('DrawTexture', win, curTex, [], dstRect);
        
        end
        
        
            DrawFormattedText( ...
            win, ...
            sprintf(speed_text), ...
            'center', yCenter - params.SPEED_CUE_OFFSET_PX, ...
            color ...
        );
    
       
             DrawFormattedText( ...
                win, ...
                sprintf('ADD MORE INSTRUCTIONS HERE'), ...
                'center', yCenter + params.SPEED_CUE_OFFSET_PX, ...
                color ...
            );
        % --- synced flip ---
        vbl = Screen('Flip', win, vbl + 0.5 * ifi);

    end


%% 
%     fprintf('speedCueOnset %g at %g  \n', speed,speedCueOnset);
%     fprintf('Wait for %g seconds\n', speedCueDur);
    [speedCueOffset] = WaitSecs(speedCueDur);
    fprintf('speedCueOffset %g\n',speedCueOffset)
end
