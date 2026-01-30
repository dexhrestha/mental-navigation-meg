function eye_stopRecording(runId,blockId)
    % stop the recording of the eye tracker
    
	message = sprintf('ending run %d for block %d', runId, blockId);
	Eyelink('Message', message);

	%stopRecording Data
	WaitSecs(0.1);
	Eyelink('StopRecording');
	Eyelink('CloseFile');
    
end
