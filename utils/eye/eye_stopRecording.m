function eye_stopRecording(runId, blockId,trialId)
    % stop the recording of the eye tracker
    
	message = sprintf('Stop recording run %d , block %d ,trial %d', runId, blockId,trialId);
	Eyelink('Message', message);

	%stopRecording Data
	WaitSecs(0.1);
	Eyelink('StopRecording');
	Eyelink('CloseFile');
    
end
