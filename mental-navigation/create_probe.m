function [probeOnset, probeOffset, probeRespKey,probeRespTime, params] = create_probe(probeCat,probeCatId,probeLoc,optionCat, params)

    win = params.ptb.window;
    bg  = params.ptb.BG_COLOR;

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
        correct_params.xCenter, params.ptb.yCenter);
    correctTex    = params.tex{probeCat, probeCatId};

    incorrectRect = CenterRectOnPointd([0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
        incorrect_params.xCenter, params.ptb.yCenter);
    incorrectTex  = params.tex{optionCat, optionCatId};

    % Draw probe
    Screen('FillRect', win, bg);
    Screen('DrawTexture', win, correctTex,   [], correctRect);
    Screen('DrawTexture', win, incorrectTex, [], incorrectRect);

    % IMPORTANT: flush queue right before timing starts, so RT is clean
    KbQueueFlush(deviceIndex);

    probeOnset = Screen('Flip', win);

    % Response struct
    probeResp = struct('key', '', 'keyCode', NaN, 'rt', NaN, 't', NaN);

    % Keys
    KbName('UnifyKeyNames');
    leftKey  = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
    escKey   = KbName('ESCAPE');

    deadline  = probeOnset + 1;
    responded = false;

    while GetSecs < deadline
        [pressed, firstPress] = KbQueueCheck(deviceIndex);

        if pressed
            % Abort on ESC any time
            if firstPress(escKey) > 0
                error('UserAbort:ESC', 'Experiment aborted by user');
            end

            if ~responded
                % first left/right during probe
                tLeft  = firstPress(leftKey);
                tRight = firstPress(rightKey);

                if tLeft > 0 || tRight > 0
                    if tLeft > 0 && (tRight == 0 || tLeft < tRight)
                        probeResp.key = -1;
                        probeResp.keyCode = leftKey;
                        probeResp.t  = tLeft;
                    else
                        probeResp.key = 1;
                        probeResp.keyCode = rightKey;
                        probeResp.t  = tRight;
                    end

                    probeResp.rt = probeResp.t - probeOnset;

                    % end probe immediately after response:
                    break;
                end
            end
        end

        WaitSecs(0.001); 
    end
    
    
    if isfield(probeResp,'key') && ~isempty(probeResp.key)
        probeRespKey = probeResp.key;
        probeRespTime = probeResp.t;
        fprintf('Response: %s\n', probeResp.key);
    else
        probeRespTime = -1;
        probeRespKey = -1;

    end
 
     % Probe offset: 
    Screen('FillRect', win, bg);
    probeOffset = Screen('Flip', win);
    
    

end
