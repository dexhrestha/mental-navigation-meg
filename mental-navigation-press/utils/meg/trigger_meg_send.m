function trigger_meg_send(value, time)
%Send trigger to the MEG
fprintf("SENDING TRIG %d for %g s",value,time)

Datapixx('SetDoutValues', value);
% synchronizing with projector now!!! with next video card flip (8.3 ms), NOT with next PTB flip.
Datapixx('RegWr'); 
WaitSecs(time); 
% set triggers back to zero
Datapixx('SetDoutValues', 0); 
Datapixx('RegWr');

end
