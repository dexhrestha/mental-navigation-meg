function [itiOnset, itiOffset,itiDa,eyeStopTime, params] = create_iti(iti_dur, params)
% CREATE_ITI
% Shows blank screen for iti_dur milliseconds, while overlapping data saving.
%
% Outputs:
%   itiOnset           - time of flip
%   itiOffset          - time when ITI ends (actual)
%   dataTransferTime   - seconds spent saving during ITI
%   remainingTime      - seconds waited after saving (can be 0)
    iti_dur = iti_dur / 1000;  % ms -> s

    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;

    xCenter = params.ptb.xCenter;
    yCenter = params.ptb.yCenter;
    
    % 1) Start ITI visually 
    Screen('FillRect', win, bg);

    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end
    
    itiOnset = Screen('Flip', win);

    % 2) Do the expensive work during ITI
    t0 = GetSecs;
    if  params.is_eye
        eye_stopRecording(params.runId, params.blockId,params.trialId);
        eyeStopTime = GetSecs; 
        eye_saveEDF(params, params.trial(params.trialId).edfFile);
    else
        eyeStopTime = NaN;
    end

    t1 = GetSecs;

    dataTransferTime = t1 - t0;              % time spent saving
    elapsedSinceOnset = t1 - itiOnset;       % total elapsed in ITI so far

    % 3) Wait only the remaining time
    target = itiOnset + iti_dur;
    remainingTime = target - GetSecs;
    if remainingTime < 0
        remainingTime = 0;
    end

    KbName('UnifyKeyNames'); 
    ifi = Screen('GetFlipInterval', win);
    speed = params.trial(params.trialId).speed;
    blinkCycle = 0.5; % same toggle cadence basis as motion-linked phases
    
    while true
        nowT = GetSecs;
        elapsedSec = nowT - itiOnset;
        phaseSlots = speed * elapsedSec;
        showStart = mod(floor(phaseSlots / blinkCycle), 2) == 0;

        Screen('FillRect', win, bg);
        drawHUD(params);
        if params.add_bars
            Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
        end
        
        if (GetSecs > target) &  showStart
            drawText(params,xCenter,yCenter,'PRESS START',params.TEXT_SIZE_PX,params.TEXT_COLOR);
        end

        itiOffset = Screen('Flip', win, nowT + 0.5 * ifi);

       pressed = check_response(params,params.START_KEY,1);
       params.trial(params.trialId).startPressed = pressed;

        if pressed && GetSecs >= target
            break;
        end
    end
    
    % Optional: log
    % fprintf('ITI dur=%.3f, elapsed=%.3f, save=%.3f, wait=%.3f, overrun=%.3f\n', ...
    %     iti_dur, elapsedSinceOnset, dataTransferTime, remainingTime, max(0, elapsedSinceOnset-iti_dur));
    itiDa = itiOffset - itiOnset;
end
