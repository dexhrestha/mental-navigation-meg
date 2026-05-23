function test_check_response_meg()

clc;
fprintf('\n=== check_response MEG release test ===\n');

% -----------------------
% INIT
% -----------------------
[~, suppressor] = LV_init_response();

params.ismeg = true;
params.kbdDeviceIndex = -1;
params.suppressor = suppressor;

% -----------------------
% PICK A REAL BUTTON TO TEST
% -----------------------
% Use your defined mapping:
% dominant = 1 → START_KEY = 8
% dominant = 2 → START_KEY = 4

params.dominant = 1;

if params.dominant == 1
    params.START_KEY = 8;
elseif params.dominant == 2
    params.START_KEY = 4;
else
    error('Invalid dominant value');
end

prev = 0;

fprintf('Press + release MEG button. ESC to quit.\n');

while true

    % HOLD MODE (continuous state)
    pressed = check_response(params, params.START_KEY, 1);

    % -----------------------
    % edge detection
    % -----------------------
    if pressed && ~prev
        fprintf('PRESS detected\n');

    elseif ~pressed && prev
        fprintf('RELEASE detected\n');
    end

    prev = pressed;

    % -----------------------
    % ESC
    % -----------------------
    [~,~,kc] = KbCheck;
    if kc(KbName('ESCAPE'))
        break;
    end

    WaitSecs(0.01);

end

fprintf('Done.\n');

end