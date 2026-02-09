function [edfFile] = eye_startRecording(eye, params)
%opt, ptb, i_run, i_block, i_trl)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % opening a new file
    % edfFile should be no more than 8 characters long
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % block number _ trial number
    % maybe add date??

    edfFile = sprintf('s%d_r%d.edf', params.session,params.runId); %data dump for eyetracking data for a subject
    Eyelink('Openfile', edfFile);
    
    % Sending a 'TRIALID' message to mark the start of a trial in Data
    % Viewer.  This is different than the start of recording message
    % START that is logged when the trial recording begins. The viewer
    % will not parse any messages, events, or samples, that exist in
    % the data file prior to this message.
    Eyelink('Message', 'run %d  block %d trial %d', params.runId, params.blockId,params.trialId);
    % This supplies the title at the bottom of the eyetracker display
    Eyelink('command', 'record_status_message "RUNID %s"', num2str(params.runId) );
        
    [winWidth, winHeight] = WindowSize(params.ptb.window);
    fixationWindow = [-params.eye.fixWinSizeLargeX -params.eye.fixWinSizeLargeY params.eye.fixWinSizeLargeX params.eye.fixWinSizeLargeY];
    fixationWindow = CenterRect(fixationWindow, params.ptb.windowRect);
    
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
    assert(eye_used == params.eye.eye_used) 
    
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