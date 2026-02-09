
% DEVELOPER variables
params.DEV_MODE = false;
params.BLOCK_RUN = false;

target = "Keyboard"; % Keyboard;   % put part of the keyboard name here
[keyboardIndices, keyboardNames] = GetKeyboardIndices;

idx = find(contains(string(keyboardNames), target, 'IgnoreCase', true), 1);

if isempty(idx)
    error("No keyboard found matching: %s", target);
end

params.kbdDeviceIndex = keyboardIndices(idx);
fprintf("Selected keyboard: %s (index %d)\n", keyboardNames{idx}, params.kbdDeviceIndex);

% Trial Phases Wait Times in Sec
params.SPEED_CUE_DUR = .25;
params.BLINK_FIX = 1;
params.TEXT_COLOR =   [255 255 255] ;           % also fine (double)
params.FIX_COLOR =  [255 0 0];
params.SPEED_CUE_LOOPS = 1;
params.BREAK_DUR = 5; % 60 seconds

% read images categories
params.N_IMAGES = 18;
params.categories = {
    'birds'
    'docile'
    'insect'
    'predators'
    'sea'
    'rep_amp'
};
params.catImages = 3;


% screen positions in deg 


%  LETTERS
params.FONT_FAMILY = 'Arial';
params.FONT_SIZE = 200;


% STIMULUS SIZES
if params.DEV_MODE

    params.START_Y_DEG          = 0.5;
    params.TARGET_Y_DEG         = 1.2;
    params.ILD_DEG              = 1.2;
    params.LM_HEIGHT_DEG        = 1.2;
    params.LM_WIDTH_DEG         = 1.2;
    params.TEXT_SIZE_DEG        = 0.3;
    params.FIX_SIZE_DEG         = 0.5;
    params.FIX_Y_DEG            = 0.5;
    params.SPEED_CUE_OFFSET_DEG = 3.0;
    params.SPEED_TEXT_DEG       = 0.3;
    params.CORRECT_OFFSET_DEG   = 2.0;
    params.INCORRECT_OFFSET_DEG = 2.0;

else

    params.START_Y_DEG          = 0.5;
    params.TARGET_Y_DEG         = 2.0;
    params.ILD_DEG              = 2.0;
    params.LM_HEIGHT_DEG        = 2.0;
    params.LM_WIDTH_DEG         = 2.0;
    params.TEXT_SIZE_DEG        = 0.5;
    params.FIX_SIZE_DEG         = 0.5;
    params.FIX_Y_DEG            = 0.5;
    params.SPEED_CUE_OFFSET_DEG = 4.0;
    params.SPEED_TEXT_DEG       = 0.3;
    params.CORRECT_OFFSET_DEG   = 4.0;
    params.INCORRECT_OFFSET_DEG = 4.0;

end 


% SCREEN SETTINGS

params.screenWidthCm =    28.5;

params.screenWidthPx = 1920;

params.viewingDistCm = 75;

params.START_Y_PX = deg2px(params.START_Y_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.TARGET_Y_PX = deg2px(params.TARGET_Y_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.ILD_PX = deg2px(params.ILD_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.LM_HEIGHT_PX = deg2px(params.LM_HEIGHT_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.LM_WIDTH_PX = deg2px(params.LM_WIDTH_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.FIX_SIZE_PX = deg2px(params.FIX_SIZE_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.FIX_Y_PX = deg2px(params.FIX_Y_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.SPEED_CUE_OFFSET_PX = deg2px(params.SPEED_CUE_OFFSET_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.CORRECT_OFFSET_PX = deg2px(params.CORRECT_OFFSET_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.INCORRECT_OFFSET_PX = deg2px(params.INCORRECT_OFFSET_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.SPEED_TEXT_PX = deg2px(params.SPEED_TEXT_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.TEXT_SIZE_PX = deg2px(params.TEXT_SIZE_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.TEXT_SIZE_PX = round(params.TEXT_SIZE_PX);
params.FIX_SIZE_PX = round(params.FIX_SIZE_PX);
params.FIX_Y_PX = round(params.FIX_Y_PX);




