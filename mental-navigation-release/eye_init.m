function [eye,params] = eye_init(params)
    el = EyelinkInitDefaults(params.ptb.window);

    eye.el = el;

    eye.el.BG_COLOR = params.ptb.BG_COLOR;
    eye.el.FG_COLOR = params.ptb.FG_COLOR;

    EyelinkUpdateDefaults(eye.el);

    eye.dummymode = 0; 

    if ~EyelinkInit(eye.dummymode,1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;
        return;

    end
    
    setup_eye_env;

    eyelink_INIT_VPixx(params.eye);

    [v,vs] = Eyelink('GetTrackerVersion');

    fprintf('Running experiment on a ''%s'' tracker .\n',vs);


end

