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
    
    
    % Keys
    KbName('UnifyKeyNames');
    escKey = KbName('ESCAPE');
    zKey     = KbName('z');
    slashKey = KbName('/?');
    probeDur = 1;% sec
    
    
    % --- at probe onset ---
    probeOnset = Screen('Flip', win);

    % Make sure we start from a known state
    [~, ~, keyCode] = KbCheck(deviceIndex);
    prevZDown     = keyCode(zKey);
    prevSlashDown = keyCode(slashKey);

    % If you REQUIRE both to be held at probe start:
    if ~(prevZDown && prevSlashDown)
        disp('Probe: No button press (both keys not held). show iti and try again');
    end

    probeResp.key  = -1;   % default: no response
    probeResp.t = -1;

    deadline = probeOnset + probeDur;

    while GetSecs < deadline
        % Check current key states
        [keyIsDown, ~, keyCode] = KbCheck(deviceIndex);

        % Abort
        if keyIsDown && keyCode(escKey)
            error('UserAbort:ESC', 'Experiment aborted by user');
        end

        zDown     = keyCode(zKey);
        slashDown = keyCode(slashKey);

        % Detect RELEASE transitions (down -> up)
        zReleased     =  prevZDown     && ~zDown;
        slashReleased =  prevSlashDown && ~slashDown;

        if zReleased || slashReleased
            tRel = GetSecs;

            % If both released in same iteration, pick one deterministically.
            % (You can't know the true order within a single poll.)
            if zReleased && ~slashReleased
                probeResp.key  = -1;      % z released first
                probeResp.t = tRel;
            elseif slashReleased && ~zReleased
                probeResp.key  = 1;       % / released first
                probeResp.t = tRel;
            else
                % both released "simultaneously" in this poll
                % choose one policy:
                probeResp.key  = 1;      % e.g., prefer / because right handed 
                probeResp.t = tRel;
            end

            break; % end probe immediately after first release
        end

        % Update previous state for next iteration
        prevZDown     = zDown;
        prevSlashDown = slashDown;

        WaitSecs(0.001);
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
    probeOffset = Screen('Flip', win);

end
