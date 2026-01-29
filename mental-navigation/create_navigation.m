function [params] = create_navigation(speed, params)
% True carousel: smooth motion + rotate IDs when passing one slot spacing.
% movementDur in ms. vbl0 is timestamp from previous Screen('Flip').
    vbl0 = Screen('Flip', params.ptb.window, [], 1);

    deviceIndex = params.kbdDeviceIndex;
    
    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;
    red = [255 0 0];

    userInput = -1;

    [xCenter, yCenter] = RectCenter(Screen('Rect', win));

	n = numel(params.trial.imgArrPos);

    % --- motion control: EXACTLY 100 px in 1 second ---
    
    % speed = 2 means move 2 images in 1 second
    % so this function should also take speed of the movment in terms of
    % distance_px_per_second
    % speed = 2 in distance_px_per_second is = 2 * params.LM_WIDTH_PX * 2
    
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

    
    KbName('UnifyKeyNames');
    kLeft  = KbName('LeftArrow');
    kRight = KbName('RightArrow');
    kStop  = KbName('s');          % or KbName('ESCAPE') if you prefer
    spaceKey = KbName('Space');
    escKey = KbName('ESCAPE');
    
    KbReleaseWait;
    vbl = vbl0;
    offsetPx = 0;
    

    while true
        % --- read keyboard every frame ---
        [keyIsDown, ~, keyCode] = KbCheck(deviceIndex);

        % defaults EVERY frame
        direction = 0;

        if keyIsDown
            if keyCode(kStop)
                break;
            end
            
            if keyCode(escKey) > 0
                error('UserAbort:ESC', 'Experiment aborted by user');
            end
            
            if keyCode(kLeft)
                direction = -1;
            elseif keyCode(kRight)
                direction = 1;
            end
        end

        % if no direction, just draw current frame (optional) or skip motion
        % (keeping draw is nice so screen doesn't "freeze" weirdly)
        offsetPx = offsetPx + dxPerFrame * direction;

        % --- rotate IDs when passing >= 1 slot ---
        stepCount = fix(offsetPx / spacingPx);
        if stepCount ~= 0
            offsetPx = offsetPx - stepCount * spacingPx;
            params.trial.imgArrShifted = circshift(params.trial.imgArrShifted, stepCount);
            % If motion direction feels reversed, swap sign:
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
            Screen('DrawTexture', win, curTex, [], dstRect);
            
        end
        
%     welcome_text = sprintf('Press s to stop.');

    
    txtColor = [255 0 0];

    % Big fixation +
    Screen('TextSize', win, 50);
    DrawFormattedText(win, '+', 'center', 'center', txtColor);

    % Smaller instruction text
    Screen('TextSize', win, 24);
    DrawFormattedText(win, 'Press esc to exit', 'center', params.ptb.yCenter - 200, [255 255 255]);

    vbl = Screen('Flip', win, vbl + 0.5 * ifi);
    end

    params.trial.imgArrPos = currPos;


end
