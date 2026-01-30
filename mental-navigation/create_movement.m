function [movementOnset, movementOffset, userInput, params] = create_movement(speed,movementDur,visual, params, vbl0)
% True carousel: smooth motion + rotate IDs when passing one slot spacing.
% movementDur in ms. vbl0 is timestamp from previous Screen('Flip').

    if nargin < 2
        error('Need movementDur and params.');
    end
    if nargin < 5 || isempty(vbl0)
        % Fallback, but this can cause blink if no frame was drawn:
        vbl0 = Screen('Flip', params.ptb.window, [], 1);
    end

    if isempty(movementDur) || ~isscalar(movementDur) || movementDur < 0
        error('movementDur must be a non-negative scalar (ms).');
    end

    movementDur = movementDur / 1000;  % ms -> s
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

    offsetPx = 0;  % smooth sub-slot offset

    movementOnset = GetSecs;
    %movementDur = 1; % test  using one second
    

    endT = movementOnset + movementDur;
    vbl = vbl0;

    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    KbReleaseWait(params.kbdDeviceIndex);
    fprintf("movementOnset %g \n  movementDur %g \n endT %g \n",movementOnset,movementDur,endT);
%     lastPrintedSec = -1 ;
    while true
        if vbl >= endT
            break;
        end

        %         elapsedSec = floor(GetSecs - movementOnset);
% 
%         if elapsedSec > lastPrintedSec
%             fprintf('%d sec\n', elapsedSec);
%             lastPrintedSec = elapsedSec;
%         end
%         
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
            visual = 1;
            if visual
                % distance from screen center in pixels
                dist = abs(currPos(k));   % because currPos is relative to center already

                % choose a falloff radius (tune this)
                fadeRadius = spacingPx * 2;   % e.g., fully visible within ~2 slots

                % map distance -> alpha in [0..255]
                alpha01 = 1 - min(dist / fadeRadius, 1);   % 1 at center, 0 far away
                alpha   = round(255 * alpha01);

                alpha01 = alpha01.^2;   % or ^3 for sharper center emphasis
                alpha   = round(255 * alpha01);

                % draw with per-image opacity
                Screen('DrawTexture', win, curTex, [], dstRect, [], [], [], [255 255 255 alpha]);
             end
        end

        % Target + fixation
        if visual
            Screen('DrawTexture', win, params.trial.targetTex, [], params.trial.targetRect);
        end
        
        DrawFormattedText(win, '+', 'center', 'center', params.FIX_COLOR);
        % --- FIXED FRAME at center slot ---
%         framePad = 6;                 % px padding around image (tune)
%         frameLineW = 5;               % border thickness (tune)
%         frameColor = [255 0 0];   % frame color (white)
% 
%         centerX = xCenter;
%         centerY = yCenter - params.START_Y_PX;
% 
%         frameRect = CenterRectOnPointd( ...
%             [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
%             centerX, centerY);
% 
%         % add padding
%         frameRect = frameRect + [-framePad -framePad framePad framePad];
% 
%         % draw outline rectangle
%         Screen('FrameRect', win, frameColor, frameRect, frameLineW);

        % --- synced flip ---
        vbl = Screen('Flip', win, vbl + 0.5 * ifi);

        % keys
        [keyIsDown, ~, keyCode] = KbCheck(params.kbdDeviceIndex);
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                sca;
                error('UserAbort:ESC', 'Experiment aborted by user');
            elseif keyCode(KbName('SPACE'))
                userInput = GetSecs;
                movementOffset = userInput;
                % Store final image x-positions
                params.trial.imgArrPos = currPos;
                return;
            end
        end
    end

    movementOffset = GetSecs;
    
    fprintf('movementOffset %g ',movementOffset)
    
    % Store final image x-positions
    params.trial.imgArrPos = currPos;

end
