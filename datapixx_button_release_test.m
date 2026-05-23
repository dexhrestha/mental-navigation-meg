function test_datapixx_release_with_init()

clc;
fprintf('\n=== Init + Release Test ===\n');

% -----------------------
% INIT
% -----------------------
[buttons, suppressor] = LV_init_response();

fprintf('Init done. Initial state: %d\n', buttons);

Datapixx('RegWrRd'); % synchronization command 

prevState = 0;

fprintf('Press/release buttons. ESC to quit.\n');

while true

    Datapixx('RegWrRd');

    raw = Datapixx('GetDinValues');
    masked = bitand(raw, suppressor);

    currentState = masked ~= 0;

    if currentState && ~prevState
        fprintf('PRESS\n');
    elseif ~currentState && prevState
        fprintf('RELEASE\n');
    end

    prevState = currentState;

    [~,~,keyCode] = KbCheck;
    if keyCode(KbName('ESCAPE'))
        break;
    end

    WaitSecs(0.01);

end

Datapixx('StopDinLog');
Datapixx('Close');

fprintf('Done.\n');

end