function [probeOnset, probeOffset, probeRespKey,probeRespTime,probeDa, params] = create_probe(probeCat,probeCatId,probeLoc,optionCat, params)

    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;
    yCenter = params.ptb.yCenter;

    yPos = yCenter - params.START_Y_DEG;

    % Use the SAME keyboard device as the rest of the experiment
    if isfield(params,'kbdDeviceIndex')
        deviceIndex = params.kbdDeviceIndex;
    else
        deviceIndex = [];  % fallback: PTB default keyboard
    end
    
    optionCatId = 2;
    % if probeLoc is 1 set correctto right 
    if probeLoc == 1
        correct_params.xCenter = params.ptb.xCenter - params.CORRECT_OFFSET_PX;
        incorrect_params.xCenter = params.ptb.xCenter + params.INCORRECT_OFFSET_PX;
    % if probeLoc is -1 set correct to left
    else 
        correct_params.xCenter = params.ptb.xCenter + params.CORRECT_OFFSET_PX;
        incorrect_params.xCenter = params.ptb.xCenter - params.INCORRECT_OFFSET_PX;
    end
    
    correctRect   = CenterRectOnPointd([0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
        correct_params.xCenter, yPos);
    correctTex    = params.tex{probeCat, probeCatId};

    incorrectRect = CenterRectOnPointd([0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
        incorrect_params.xCenter, yPos);
    optionCat = mod(probeCat + optionCat - 1, 6) + 1;
    incorrectTex  = params.tex{optionCat, optionCatId};
    
    sprintf('opt %d , probe %d',optionCat,probeCat);
    
    % Draw probe
    Screen('FillRect', win, bg);
    Screen('DrawTexture', win, correctTex,   [], correctRect);
    Screen('DrawTexture', win, incorrectTex, [], incorrectRect);

    % IMPORTANT: flush queue right before timing starts, so RT is clean
    KbQueueFlush(deviceIndex);
    
    
    % Keys
    KbName('UnifyKeyNames');
    
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
    escKey = KbName('ESCAPE');

    probeDur = 1;% sec
   
    % --- at probe onset ---
    probeResp.key  = 0;   % default: no response
    probeResp.t = -1;
    probeResp.rt = -1;
    
    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 
    
    probeOnset = Screen('Flip', win);
    KbQueueFlush(deviceIndex);
    
    deadline = probeOnset + probeDur;
    
    probeResp.key = 0;
    probeResp.t   = -1;
    probeResp.rt  = -1;
    
    while GetSecs < deadline
        [pressed, firstPress] = KbQueueCheck(deviceIndex);
        if pressed
            if firstPress(escKey) > 0
                error('UserAbort:ESC', 'Experiment aborted by user');
            end
    
            tLeft  = firstPress(leftKey);
            tRight = firstPress(rightKey);
    
            if tLeft > 0 || tRight > 0
                if tLeft > 0 && (tRight == 0 || tLeft < tRight)
                    probeResp.key = -1;
                    probeResp.t   = tLeft;
                else
                    probeResp.key = 1;
                    probeResp.t   = tRight;
                end
    
                % IMPORTANT: use the SAME timebase for onset.
                % Convert onset to GetSecs base by using probeOnset itself (ok if clocks match)
                probeResp.rt = probeResp.t - probeOnset;
                break;
            end
        end
    end

    

     % Probe offset: 
    Screen('FillRect', win, bg);

    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 
    probeOffset = Screen('Flip', win, probeOnset + probeDur - 0.5*params.ptb.ifi);

    if isfield(probeResp,'key') && ~isempty(probeResp.key)
        probeRespKey = probeResp.key;
        probeRespTime = probeResp.t;
        fprintf('Response: %d\n', probeResp.key);
    else
        probeRespTime = -1;
        probeRespKey = -1;

    end

    probeDa = probeOffset - probeOnset; 
    
end
