%% checkEyeFixation: function description
function [valid] = eye_checkFixation(filename, params)
    % checks if the eye position was within the fixation window during the
    % trial, returns a boolean
    
	%load the edf into a mat file
	
	%---requirements-----------------------------------------+
	% requires the eyelink sdk to be installed on the system +
	% requires the following library as well				 +
	% kobi.nat.uni-magdeburg.de/edfImport 					 +
	% already uploaded to our github 						 +
	%---------------------------------------------------------

	Trials = edfImport(filename, [1 1 1]); % this loads everything into the structure
    
    % +1 because you have 0 and 1 for left and right
    
    eye_used = params.eye.eye_used;
    if any(params.eye.eye_used == [0 1])
        % +1 as we're accessing MATLAB array
        eye_used=eye_used+1;
    end
	gazex = Trials.Samples.gx(eye_used, :);
	gazey = Trials.Samples.gy(eye_used, :);

	% define the box around the fixation cross
	% maybe use visual angle, that would just be the hypoteneuse
	fixationWindow = [-params.eye.fixWinSizeLargeX -params.eye.fixWinSizeLargeY params.eye.fixWinSizeLargeX params.eye.fixWinSizeLargeY];
	fixationWindow = CenterRect(fixationWindow, params.ptb.windowRect);
	totalSampleLength = length(gazex);
	totalValidSamples = 0;
	for idx=1:totalSampleLength
		mx = gazex(idx);
		my = gazey(idx);

		fixations = mx > fixationWindow(1) &&  mx <  fixationWindow(3) && my > fixationWindow(2) && my < fixationWindow(4);
		
		if fixations==true
			totalValidSamples = totalValidSamples+1;
		end	
	end
	valid = false;
	if totalValidSamples>params.eye.fix_perc*totalSampleLength
		valid = true;
	end
end