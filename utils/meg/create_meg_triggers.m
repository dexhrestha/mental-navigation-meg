function triggers = create_meg_triggers()
    
    triggers = struct();
    
    % trial 
    
    % speed triggers?
    triggers.SPEED_1 = 160; % 1.6 hZ speed 
    triggers.SPEED_2 = 200; % 2 hz speed
    % start trig
    
    % TEST STARTS WITH 5x
    triggers.MOV_START = 90; % change to movement start
    % movement stop
    triggers.MOV_END = 60;

    % probe end trig
    triggers.PROBE_END= 53;
    
    % Break start with 6x
    % probe end trig
    triggers.BRK_START= 95;
    triggers.BRK_END= 65;
end
