% Trial Phases Wait Times in Sec
params.BLINK_FIX = 1;
params.TEXT_COLOR =  uint8([255 255 255]);           % also fine (double)

% read images categories
params.categories = {
    'birds'
    'docile'
    'insect'
    'predators'
    'sea'
    'rep_amp'
};

% screen positions in px 
params.START_Y_PX = 50+25;
params.TARGET_Y_PX = 50+25;
params.ILD_PX = 50;
params.LM_HEIGHT = 50;
params.LM_WIDTH = 50;
params.FIX_SIZE_PX    = 12;

params.CORRECT_OFFEST_X = 200;
params.INCORRECT_OFFEST_X = 200;
 
% participant variables
params.participant.name = '001';
params.participant.session = 1;
params.participant.direction = 1 ; % -1 for left | +1 for right

% DEVELOPER variables
params.DEV_MODE = true;
params.BLOCK_TRIAL = false;

