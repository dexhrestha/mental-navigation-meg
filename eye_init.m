function eye = eye_init(win,params)
    el = EyelinkInitDefaults(win);

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

    eyelink_INIT_VPixx(params);

    [v,vs] = Eyelink('GetTrackerVersion');

    fprintf('Running experiment on a ''%s'' tracker .\n',vs);


end

