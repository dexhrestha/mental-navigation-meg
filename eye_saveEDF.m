%% saveedf: saves the edf file for each trial, and moves it to the proper folder for the subject
function [statusA,statusB, savedFilename] = saveEDF(stim, opt, edfFile, blocknumber,trialnumber)
	
	%transfer file to local machine
	try
		fprintf('Receiving data file ''%s''\n', edfFile );
		statusA = Eyelink('ReceiveFile');
		if statusA  > 0
		    fprintf('ReceiveFile status %d\n', statusA);
		end
		if 2==exist(edfFile, 'file')
    		fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
        
        %change filename and move to subject specific directory
        savedFilename = [opt.subj_dir stim.subid '_b' num2str(blocknumber) '_t' num2str(trialnumber) '.edf'];
        statusB = movefile(edfFile, savedFilename);
	
        if 0==statusB
            fprintf('problem removing the data file for %d,%d', blocknumber,trialnumber);
        end
	catch rdf
		fprintf('Problem receiving data file ''%s''\n', edfFile );
		rdf;
        statusA = -1;
        statusB = -1;
        savedFilename = 'blah';
	end


end