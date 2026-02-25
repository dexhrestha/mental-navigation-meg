% calibration of the eye tracker
function eye_calibration(eye,params)
    edfFile = sprintf('c_r%d.edf', params.runId); %data dump for eyetracking data for a subject
    Eyelink('Openfile', edfFile);
    
    EyelinkDoTrackerSetup(eye.el);
    Eyelink('Message','Calibration sucessful');

    WaitSecs(0.1);
    
    Eyelink('CloseFile');
    try
		fprintf('Receiving data file ''%s''\n', edfFile );
		statusA = Eyelink('ReceiveFile');
		
        if statusA  > 0
		    fprintf('ReceiveFile status %d\n', statusA);
        end
        
		if exist(edfFile, 'file')
    		fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
        
        %change filename and move to subject specific directory
        savedFilename = fullfile(params.eye_out_dir ,['calib_r' num2str(params.runId) '.edf']);
        statusB = movefile(edfFile, savedFilename);
	
        if 0==statusB
            fprintf('problem removing the data file for %d,%d', params);
        end
	catch rdf
		fprintf('Problem receiving data file ''%s''\n', edfFile );
		rdf;
        statusA = -1;
        statusB = -1;
        savedFilename = 'blah';
    end
    %EyelinkDoDriftCorrection(eye.el); %check drift correction once 
    %check if drift correction is needed or not, causes a fixation cross to
    %appear
end
