function flag = eye_beginTrialFixation(eye, ptb, opt, fix_color)
% checks whether the eye position is in the fixation window to allow trial
% to start

% get the size of the window screen
[winWidth, winHeight] = WindowSize(ptb.window);

% generate fixation window
fixationWindow = [-opt.fixWinSizeSmallX -opt.fixWinSizeSmallY opt.fixWinSizeSmallX opt.fixWinSizeSmallY];
fixationWindow = fix(CenterRect(fixationWindow, ptb.window_rect));

% draw white diode, so there will be a bigger constrast when
% the trial starts
Screen('FillRect',ptb.window, [255, 255, 255], ptb.diode);
% draw fixation dot
Screen('FillOval', ptb.window, fix_color, ...
    [(ptb.x_center-opt.stimSize) (ptb.y_center-opt.stimSize) ...
    (ptb.x_center+opt.stimSize) (ptb.y_center+opt.stimSize)], []);
Screen('Flip', ptb.window); %re-flip to show what you have drawn

% now set up eyetracker
if Eyelink('IsConnected')~=1 && ~eye.dummymode
    cleanup;
    return;
end;

Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);

Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);

[v,vs] = Eyelink('GetTrackerVersion');
%fprintf('Running experiment on a ''%s'' tracker.\n', vs );
vsn = regexp(vs,'\d','match');

if v ==3 && str2double(vsn{1}) == 4 % if EL 1000 and tracker version 4.xx
    
    % remote mode possible add HTARGET ( head target)
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT,HTARGET');
    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET');
else
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
end


% if ~eye.dummymode
%     % Hide the mouse cursor and setup the eye calibration window
%     Screen('HideCursorHelper', ptb.window);
% end

% WaitSecs(1);
% STEP 7.1
% Sending a 'TRIALID' message to mark the start of a trial in Data
% Viewer.  This is different than the start of recording message
% START that is logged when the trial recording begins. The viewer
% will not parse any messages, events, or samples, that exist in
% the data file prior to this message.
Eyelink('Message', 'TRIAL starts');
% This supplies the title at the bottom of the eyetracker display
Eyelink('Command', 'set_idle_mode');
% clear tracker display and draw box at center
Eyelink('Command', 'clear_screen %d', 0);
% draw fixation and fixation window shapes on host PC
Eyelink('command', 'draw_cross %d %d 15', winWidth/2,winHeight/2);
Eyelink('command', 'draw_box %d %d %d %d 15', fixationWindow(1), fixationWindow(2), fixationWindow(3), fixationWindow(4));

Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);
Eyelink('StartRecording');

% now check that this is the eye we selected
eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
% returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR) depending on what data is
if eye_used ~= opt.eye_used
    Eyelink('StopRecording');
    assert(eye_used == opt.eye_used, 'recording from a different eye than specified')
end

if any(opt.eye_used == [0 1])
    % +1 as we're accessing MATLAB array
    eye_used=eye_used+1;
end

% record a few samples before we actually start displaying
% otherwise you may lose a few msec of data

% so that mx and my are defined beforehand
mx = 99999;
my = 99999;
WaitSecs(0.1);
firstFixation = false;
startCheck = GetSecs(); 
while true %% if the subject doesnot fixate, the trial never starts
    
    if eye.dummymode==0
        error=Eyelink('CheckRecording');
        if(error~=0)
            break;
        end
        
        if Eyelink( 'NewFloatSampleAvailable') > 0
            % get the sample in the form of an event structure
            evt = Eyelink( 'NewestFloatSample');
            
            % if we do, get current gaze position from sample
            x = evt.gx(eye_used); % +1 as we're accessing MATLAB array
            y = evt.gy(eye_used);
            % do we have valid data and is the pupil visible?
            if x~=eye.el.MISSING_DATA && y~=eye.el.MISSING_DATA %&& evt.pa(eye_used+1)>0 % this is because we are trying out with a mouse
                mx=x;
                my=y;
            end
        end
    else
        % Query current mouse cursor position (our "pseudo-eyetracker") -
        % (mx,my) is our gaze position.
        %[mx, my]=GetMouse(window); %#ok<*NASGU>
    end
    
    infix=0;
    if infixationWindow(mx,my)
        if firstFixation == false
            % ensure that the subject if fixating for a given length 
            % of time,reset if they move out of the fixation window
            startFixation = GetSecs(); 
            firstFixation = true;
        end
        Eyelink('Message', 'Fixation Start');
        Eyelink('command', 'record_status_message "Fixation start"');
        Eyelink('command', 'record_status_message "X/Y %d/%d"', fix(mx),fix(my));
        %Beeper(eye.el.calibration_success_beep(1),eye.el.calibration_success_beep(2),eye.el.calibration_success_beep(3));
        infix = 1;
    else
        infix=0;
        firstFixation = false;
    end

    
    if  infix==1 && GetSecs()-startFixation > opt.fixationTime
        % if the participant has looked inside the fixation window for the
        % expected duration
        WaitSecs(0.1);
        Eyelink('StopRecording');
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.5);
        disp('proper fixation');
        Eyelink('Command', 'clear_screen %d', 0);
        return; %% return to main experiment
    
    elseif  infix==1 && GetSecs()-startFixation > floor(opt.fixationTime/2) && ...
            GetSecs()-startCheck > opt.maxFixationTime
        % if its after the maximum fixation time, reduce the duration of
        % the fixation time required to half
        WaitSecs(0.1);
        Eyelink('StopRecording');
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.5);
        disp('proper fixation');
        Eyelink('Command', 'clear_screen %d', 0);
        return; %% return to main experiment
        
    elseif GetSecs()-startCheck > opt.maxFixationTime
        % if the participant has been trying to start the trial for more
        % than 15 s, it is likely that there is some problem with the eye
        % tracker. here we manually start the trial
        stopkey=KbName('w');
        sprintf('press w to force trial start')
        [keyIsDown,secs,keyCode] = KbCheck; %#ok<*ASGLU>
        % if stopkey was pressed, stop display
        if keyCode(stopkey)
            sprintf('Stopkey pressed, starting trial manually\n');
            Eyelink('Message', 'Key pressed, forcing trial start');
            return;
        end
    
    end
    % elseif ~infixationWindow(mx,my) && infix && GetSecs > graceTime
        
    %     disp('broke fix');
    %     Eyelink('command', 'record_status_message "Fixation broke"');
    %     %Eyelink('Message', 'Fixation broke or grace time ended');
    %     %Beeper(el.calibration_failed_beep(1), el.calibration_failed_beep(2), el.calibration_failed_beep(3));
    %     infix = 0;
    % end

    %just to force the loop to close if anything weird happens
    % stopkey=KbName('w');
    % [keyIsDown,secs,keyCode] = KbCheck; %#ok<*ASGLU>
    % % if spacebar was pressed stop display
    % if keyCode(stopkey)
    %     sprintf('Space pressed, exiting trial\n');
    %     Eyelink('Message', 'Key pressed');
    %     break;
    % end
end

    function fix = infixationWindow(mx,my)
        % determine if gx and gy are within fixation window
        fix = mx > fixationWindow(1) &&  mx <  fixationWindow(3) && ...
            my > fixationWindow(2) && my < fixationWindow(4) ;
    end

end