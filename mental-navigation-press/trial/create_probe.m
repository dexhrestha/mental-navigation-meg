function [probeOnset, probeOffset, probeRespKey,probeRespTime, params] = create_probe(probeCat,probeCatId,probeLoc,optionCat, params)

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
    incorrectTex  = params.tex{optionCat, optionCatId};

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
    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 
    probeOnset = Screen('Flip', win); 
   
    probeResp.key  = 0;   % default: no response
    probeResp.t = -1;
    probeResp.rt = -1;

    deadline = probeOnset + probeDur;
    responded = false; 
    
    while GetSecs < deadline
        % Check current key states
        [keyIsDown, firstPress] = KbQueueCheck(deviceIndex);

        % Abort
        if keyIsDown 
            if firstPress(escKey) > 0
                error('UserAbort:ESC', 'Experiment aborted by user');
            elseif ~responded
                tLeft = firstPress(leftKey);
                tRight = firstPress(rightKey);
                
                if tLeft > 0 || tRight >0
                    if tLeft > 0 && (tRight == 0 || tLeft < tRight)
                        probeResp.key = -1;
                        probeResp.t = tLeft;
                        
                    else
                        probeResp.key = 1;
                        probeResp.t = tRight;
                        
                    end
                    probeResp.rt = probeResp.t - probeOnset;
                    % responded = true;
                    break;
                end
            end
        end
    end
    
    if isfield(probeResp,'key') && ~isempty(probeResp.key)
        probeRespKey = probeResp.key;
        probeRespTime = probeResp.t;
        fprintf('Response: %d\n', probeResp.key);
    else
        probeRespTime = -1;
        probeRespKey = -1;

    end

     % Probe offset: 
    Screen('FillRect', win, bg);
    if params.add_bars
        Screen('FillRect', win, params.Bars.barColor, params.Bars.sideBarRects);
    end 
    probeOffset = Screen('Flip', win);

end
