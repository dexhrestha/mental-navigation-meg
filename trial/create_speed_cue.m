function [speedCueOnset, speedCueOffset, speedCueDa, params] = create_speed_cue( params)

    

    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;
    color = params.TEXT_COLOR;

    xCenter = params.ptb.xCenter;
    yCenter = params.ptb.yCenter; 

    ifi = Screen('GetFlipInterval', win);
    speed = params.trial.speed;
    %% --------------------------------------------------------------------
    % Speed text
    %% --------------------------------------------------------------------
    if params.lang == 1

        if speed == 2
            speed_text = 'VELOCE';
        else
            speed_text = 'LENTO';
        end

        if params.trial.visual
            speed_text = strcat(speed_text, '\n', 'GIORNO');
        else
            speed_text = strcat(speed_text, '\n', 'NOTTE');
        end

    else

        if speed == 2
            speed_text = 'FAST';
        else
            speed_text = 'SLOW';
        end

        if params.trial.visual
            speed_text = strcat(speed_text, '\n', 'DAY');
        else
            speed_text = strcat(speed_text, '\n', 'NIGHT');
        end
    end

    %% --------------------------------------------------------------------
    % Initialize carousel image order exactly like before
    %% --------------------------------------------------------------------
    imgArr = 1:params.N_IMAGES;
    N = numel(imgArr);

    startId = ceil(N / 2) + 1;
    centerIdx = ceil(N / 2) + 1;

    currIdx = find(imgArr == startId, 1);
    shiftAmount = centerIdx - currIdx;

    params.trial.imgArrShifted = circshift(imgArr, shiftAmount);

    params.trial.imgArrPos = ((1:N) - centerIdx) * ...
        (params.LM_WIDTH_PX + params.ILD_PX);

    n = numel(params.trial.imgArrPos);
    basePos = params.trial.imgArrPos(:)';

    baseSorted = sort(basePos);
    spacingPx = median(diff(baseSorted));

    if ~isfinite(spacingPx) || spacingPx <= 0
        spacingPx = params.LM_WIDTH_PX * 2;
    end

    %% --------------------------------------------------------------------
    % Match movement-function motion scale
    %% --------------------------------------------------------------------
    speedPxPerSec = speed * spacingPx;
    dxPerFrame = speedPxPerSec * ifi;

    offsetPx = 0;
    traveledSlots = 0;

    % Keep your existing cue-duration logic.
    % If you want the cue to use params.SPEED_CUE_DUR instead, replace this
    % line with: movementDur = speedCueDur;
    movementDur = params.N_IMAGES / speed * params.SPEED_CUE_LOOPS;

    %% --------------------------------------------------------------------
    % PTB setup
    %% --------------------------------------------------------------------
    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('TextSize', win, round(double(params.SPEED_TEXT_PX)));
    blinkCycle = 0.5; % toggle every half image-slot shift
 
    if ~isfield(params, 'FIX_COLOR')
        params.FIX_COLOR = [255 0 0];
    end

    yPos = yCenter - params.START_Y_PX;

    %% --------------------------------------------------------------------
    % Draw first frame before onset flip
    %% --------------------------------------------------------------------
    Screen('FillRect', win, bg);

 

    DrawFormattedText( ...
        win, ...
        sprintf(speed_text), ...
        'center', ...
        yCenter - params.SPEED_CUE_OFFSET_PX, ...
        color);

    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end

    speedCueOnset = Screen('Flip', win);

    vbl = speedCueOnset;

    KbName('UnifyKeyNames');
   
    %% --------------------------------------------------------------------
    % Main speed-cue loop
    %% --------------------------------------------------------------------
    while true

        Screen('FillRect', win, bg);

        %% Carousel update: match movement function
        deltaPx = dxPerFrame * params.participant.direction;
        offsetPx = offsetPx + deltaPx;
        traveledSlots = traveledSlots + abs(deltaPx) / spacingPx;

        stepCount = fix(offsetPx / spacingPx);

        if stepCount ~= 0
            offsetPx = offsetPx - stepCount * spacingPx;
            params.trial.imgArrShifted = circshift( ...
                params.trial.imgArrShifted, stepCount);
        end

        currPos = basePos + offsetPx; 
        loopReady = traveledSlots >= params.N_IMAGES;

        %% Starfield
        params.star.speed = (speedPxPerSec / params.star.focalLength) * 0.25;
        params.star = drawHyperspaceStarfield(params);

        %% Central carousel image presentation
        drawImages( ...
            win, params, currPos, spacingPx, xCenter, yPos, ...
            n);

        %% Fixation
        drawFixation(params, xCenter, yPos);
        

         
        %% Speed/day-night text overlay
         

        DrawFormattedText( ...
            win, ...
            sprintf(speed_text), ...
            'center', ...
            yCenter - params.SPEED_CUE_OFFSET_PX, ...
            color);

        
        %% HUD
        drawHUD(params);
        %% Optional side bars
        if params.add_bars
            Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
        end

        %% Flip
        vbl = Screen('Flip', win, vbl + 0.5 * ifi); 

        if loopReady 
            break;
        end
    end

    speedCueOffset = vbl;
    speedCueDa = speedCueOffset - speedCueOnset;

end
