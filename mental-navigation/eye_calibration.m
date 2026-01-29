% calibration of the eye tracker
function eye_calibration(eye)
    
    EyelinkDoTrackerSetup(eye.el);
    
    %EyelinkDoDriftCorrection(eye.el); %check drift correction once 
    %check if drift correction is needed or not, causes a fixation cross to
    %appear
end
