function [edfFile] = eye_startRecording(eye, opt, ptb, i_block, i_trl, trl_stim)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % opening a new file
    % edfFile should be no more than 8 characters long
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % block number _ trial number
    edfFile = sprintf('%d_%d.edf', i_block, i_trl); %data dump for eyetracking data for a subject
    Eyelink('Openfile', edfFile);
    
    % Sending a 'TRIALID' message to mark the start of a trial in Data
    % Viewer.  This is different than the start of recording message
    % START that is logged when the trial recording begins. The viewer
    % will not parse any messages, events, or samples, that exist in
    % the data file prior to this message.
    Eyelink('Message', 'trial %d block %d', i_trl, i_block);
    % This supplies the title at the bottom of the eyetracker display
    Eyelink('command', 'record_status_message "TRIAL %s/%d"', num2str(i_trl), opt.n_trls_in_block);
        
    [winWidth, winHeight] = WindowSize(ptb.window);
    fixationWindow = [-opt.fixWinSizeLargeX -opt.fixWinSizeLargeY opt.fixWinSizeLargeX opt.fixWinSizeLargeY];
    fixationWindow = CenterRect(fixationWindow, ptb.window_rect);
    
    Eyelink('Command', 'clear_screen %d', 0);
    % draw fixation and fixation window shapes on host PC
    Eyelink('command', 'draw_cross %d %d 15', winWidth/2,winHeight/2);
    Eyelink('command', 'draw_box %d %d %d %d 15', fix(fixationWindow(1)), fix(fixationWindow(2)), fix(fixationWindow(3)), fix(fixationWindow(4)));
    
    %also start eye-tracking
    %recordingStartTime=GetSecs(); % we use this to get the queued data
    Eyelink('StartRecording');
    % record a few samples before we actually start displaying
    WaitSecs(0.1);
    
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    assert(eye_used == opt.eye_used) 
    
    % mark zero-plot time in data file
    Eyelink('Message', 'SYNCTIME');
    %stopkey=KbName('space'); %do we need a stopkey?
    
    % check if is recording
    err=Eyelink('CheckRecording');
    if(err~=0)
        err
        error('checkrecording problem')
    end
end 