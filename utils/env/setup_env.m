%% Input data source
params.COHORT_DIR =  'pilot_MEG'; % cohort
%% DEVELOPER variables
params.DEV_MODE = true;
params.BLOCK_RUN = false;
params.CENTRAL = true;
%% Get Keyboard
target = "Keyboard"; % Keyboard;   % put part of the keyboard name here
[keyboardIndices, keyboardNames] = GetKeyboardIndices;

idx = find(contains(string(keyboardNames), target, 'IgnoreCase', true), 1);

if isempty(idx)
    error("No keyboard found matching: %s", target);
end

params.kbdDeviceIndex = keyboardIndices(idx);
fprintf("Selected keyboard: %s (index %d)\n", keyboardNames{idx}, params.kbdDeviceIndex);

%% Trial Phases Wait Times in Sec
params.SPEED_CUE_DUR = .25;
params.BLINK_FIX_RED_DUR = .8;
params.BLINK_FIX_OFF_DUR = .05;
params.BLINK_FIX_GREEN_DUR = 1;

params.TEXT_COLOR =   [255 255 255] ;           % also fine (double)

params.FIX_COLOR =  [255 0 0];
params.SPEED_CUE_LOOPS = 1;
if params.DEV_MODE
    params.BREAK_DUR = 5 ; % 60 seconds
else
    params.BREAK_DUR = 60 ; % 60 seconds
end
%% read images categories
params.N_IMAGES = 18;
params.categories = {
    'cat'
    'cow'
    'dog'
    'fox'
    'bear'
    'rooster'
};
params.catImages = 3;
%%  LETTERS
params.FONT_FAMILY = 'Arial';
params.FONT_SIZE = 200;
%% STIMULUS SIZES
if params.DEV_MODE
    params.START_Y_DEG          = 0;
    params.TARGET_Y_DEG         = 1.5;
    params.ILD_DEG              = 1;
    params.LM_HEIGHT_DEG        = 1.;
    params.LM_WIDTH_DEG         = 1;
    params.TEXT_SIZE_DEG        = 0.3;
    params.FIX_SIZE_DEG         = 0.3; 
    params.SPEED_CUE_OFFSET_DEG = 3.0;
    params.SPEED_TEXT_DEG       = 0.3;
    params.CORRECT_OFFSET_DEG   = 2.0;
    params.INCORRECT_OFFSET_DEG = 2.0;

else

    params.START_Y_DEG          = 0;
    params.TARGET_Y_DEG         = 3.5;
    params.ILD_DEG              = 2;
    params.LM_HEIGHT_DEG        = 2.;
    params.LM_WIDTH_DEG         = 2;
    params.TEXT_SIZE_DEG        = 0.6;
    params.FIX_SIZE_DEG         = 0.4; 
    params.SPEED_CUE_OFFSET_DEG = 3.0;
    params.SPEED_TEXT_DEG       = 0.6;
    params.CORRECT_OFFSET_DEG   = 3.5;
    params.INCORRECT_OFFSET_DEG = 3.5;

end 
%% SCREEN SETTINGS


params.SCREEN_WIDTH_CM =    28.5;

%% add bars for meg
if params.DEV_MODE
    params.SCREEN_WIDTH_PX = 600;
else
    params.SCREEN_WIDTH_PX = 1920;
end

params.VIEWING_DIST_CM = 75;

params.START_Y_PX = deg2px(params.START_Y_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.TARGET_Y_PX = deg2px(params.TARGET_Y_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.ILD_PX = deg2px(params.ILD_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.LM_HEIGHT_PX = deg2px(params.LM_HEIGHT_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.LM_WIDTH_PX = deg2px(params.LM_WIDTH_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.FIX_SIZE_PX = deg2px(params.FIX_SIZE_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.SPEED_CUE_OFFSET_PX = deg2px(params.SPEED_CUE_OFFSET_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.CORRECT_OFFSET_PX = deg2px(params.CORRECT_OFFSET_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.INCORRECT_OFFSET_PX = deg2px(params.INCORRECT_OFFSET_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.SPEED_TEXT_PX = deg2px(params.SPEED_TEXT_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.TEXT_SIZE_PX = deg2px(params.TEXT_SIZE_DEG, ...
    params.SCREEN_WIDTH_CM, params.SCREEN_WIDTH_PX, params.VIEWING_DIST_CM);

params.TEXT_SIZE_PX = round(params.TEXT_SIZE_PX);
params.FIX_SIZE_PX = round(params.FIX_SIZE_PX);
 

