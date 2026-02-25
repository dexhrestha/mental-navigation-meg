function initialValues = trigger_meg_init
% Open Datapixx, and stop any schedules which might already be running
 

%  Open Datapixx, and stop any schedules which might already be running
Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('EnableDinDebounce');
Datapixx('RegWrRd');   
% Show how many TTL input bits are in the Datapixx
nBits = Datapixx('GetDinNumBits');
fprintf('\nDatapixx has %d TTL input bits\n', nBits);

% Stato iniziale
fprintf('Initial digital input states = ');
initialValues = Datapixx('GetDinValues');
for bit = nBits-1:-1:0               % Easier to understand if we show in binary
    if (bitand(initialValues, 2^bit) > 0)
        fprintf('1');
    else
        fprintf('0');
    end
end
fprintf('\n');

end
