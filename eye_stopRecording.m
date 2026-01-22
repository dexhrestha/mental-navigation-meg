function eye_stopRecording(blocknumber, trialnumber)
    % stop the recording of the eye tracker
    
	message = sprintf('ending trial %d for block %d', trialnumber, blocknumber);
	Eyelink('Message', message);

	%stopRecording Data
	WaitSecs(0.1);
	Eyelink('StopRecording');
	Eyelink('CloseFile');
    
end
