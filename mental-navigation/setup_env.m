% Trial Phases Wait Times in Sec
params.SPEED_CUE_DUR = .25;
params.BLINK_FIX = 1;
params.TEXT_COLOR =  uint8([255 255 255]);           % also fine (double)
params.SPEED_CUE_LOOPS = 1;

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
% DEVELOPER variables
params.DEV_MODE = false;
params.BLOCK_RUN = true;

%  LETTERS
params.FONT_FAMILY = 'Arial';
params.FONT_SIZE = 200;


% STIMULUS SIZES
if params.DEV_MODE
    params.START_Y_DEG          = 1.2;
    params.TARGET_Y_DEG         = 1.2;
    params.ILD_DEG              = 1.2;

    params.LM_HEIGHT_DEG        = 1.2;
    params.LM_WIDTH_DEG         = 1.2;

    params.FIX_SIZE_DEG         = 0.5;

    params.SPEED_CUE_OFFSET_DEG = 3.0;

    params.CORRECT_OFFSET_DEG   = 2.0;
    params.INCORRECT_OFFSET_DEG = 2.0;
    
    
else 
    params.START_Y_DEG          = 2.0;
    params.TARGET_Y_DEG         = 2.0;
    params.ILD_DEG              = 2.0;

    params.LM_HEIGHT_DEG        = 2.0;
    params.LM_WIDTH_DEG         = 2.0;

    params.FIX_SIZE_DEG         = .8;

    params.SPEED_CUE_OFFSET_DEG = 4.0;

    params.CORRECT_OFFSET_DEG   = 4.0;
    params.INCORRECT_OFFSET_DEG = 4.0;
end 

% SCREEN SETTINGS

params.screenWidthCm =  28.5; %28.5;

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

params.SPEED_CUE_OFFSET_PX = deg2px(params.SPEED_CUE_OFFSET_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.CORRECT_OFFSET_PX = deg2px(params.CORRECT_OFFSET_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.INCORRECT_OFFSET_PX = deg2px(params.INCORRECT_OFFSET_DEG, ...
    params.screenWidthCm, params.screenWidthPx, params.viewingDistCm);

params.FIX_SIZE_PX = round(params.FIX_SIZE_PX);


