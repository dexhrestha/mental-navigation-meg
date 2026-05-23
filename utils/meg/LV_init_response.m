function [buttons,suppressor] = LV_init_response

Datapixx('StopDinLog');
Datapixx('RegWrRd');    % Synchronize Datapixx registers to local register cache

Datapixx('SetDinDataDirection', hex2dec('1F0000'));
Datapixx('SetDinDataOut', hex2dec('1F0000'));
Datapixx('SetDinDataOutStrength', 0);   % Set brightness of buttons
Datapixx('RegWrRd');

%num_Bits = Datapixx('GetDinNumBits');

suppressor = 2^0 + 2^1 + 2^2 + 2^3; %build a mask of unused input channels

% Fire up the logger
Datapixx('EnableDinDebounce');      % Filter out button bounce
Datapixx('SetDinLog');              % Configure logging with default values
Datapixx('StartDinLog');
Datapixx('RegWrRd');

buttons = bitand(Datapixx('GetDinValues'),suppressor);
end
