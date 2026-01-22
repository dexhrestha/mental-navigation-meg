function [probeOnset, probeOffset, probeResp, params] = create_probe(probeCat,probeCatId,probeLoc,optionCat, params)

    win = params.window;
    bg  = params.BG_COLOR;

    % Use the SAME keyboard device as the rest of the experiment
    if isfield(params,'kbdDeviceIndex')
        deviceIndex = params.kbdDeviceIndex;
    else
        deviceIndex = [];  % fallback: PTB default keyboard
    end

    [xCenter, yCenter] = RectCenter(Screen('Rect', win));


    optionCatId = 2;
    % if probeLoc is 1 set correctto right 
    if probeLoc == 1
        correct_xCenter = xCenter - params.CORRECT_OFFEST_X;
        incorrect_xCenter = xCenter + params.INCORRECT_OFFEST_X;
    % if probeLoc is -1 set correct to left
    else 
        correct_xCenter = xCenter + params.CORRECT_OFFEST_X;
        incorrect_xCenter = xCenter - params.INCORRECT_OFFEST_X;
    end
    
    correctRect   = CenterRectOnPointd([0 0 params.LM_WIDTH params.LM_HEIGHT], ...
        correct_xCenter, yCenter);
    correctTex    = params.tex{probeCat, probeCatId};

    incorrectRect = CenterRectOnPointd([0 0 params.LM_WIDTH params.LM_HEIGHT], ...
        incorrect_xCenter, yCenter);
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
                        probeResp.key = 'left';
                        probeResp.keyCode = leftKey;
                        probeResp.t  = tLeft;
                    else
                        probeResp.key = 'right';
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
        fprintf('Response: %s\n', probeResp.key);
    end

    % Probe offset: 
    Screen('FillRect', win, bg);
    probeOffset = Screen('Flip', win);

end
