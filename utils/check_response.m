function pressed = check_response(params, key, hold)

persistent prevState

if isempty(prevState)
    prevState = 0;
end

if nargin < 3 || isempty(hold)
    hold = 0;
end

pressed = 0;

% -----------------------
% ESC check (keyboard only)
% -----------------------
escKey = KbName('ESCAPE');
[keyIsDown,~,keyCode] = KbCheck(params.kbdDeviceIndex);

if keyIsDown && keyCode(escKey)
    sca;
    error('UserAbort:ESC', 'Experiment aborted by user');
end

% -----------------------
% MEG INPUT
% -----------------------
if params.ismeg

    Datapixx('RegWrRd');

    raw = Datapixx('GetDinValues');

    %mask relevant bits
    buttonState = bitand(raw, params.suppressor);

    %use BIT TEST, not equality
    currentState = bitand(buttonState, key) ~= 0;

else

    currentState = keyCode(key);

end

% -----------------------
% HOLD vs EDGE
% -----------------------
if hold
    pressed = currentState;
else
    pressed = currentState && ~prevState;
end

prevState = currentState;

end