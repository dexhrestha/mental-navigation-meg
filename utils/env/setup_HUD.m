function [params] = setup_HUD(params) 
    win = params.ptb.window;    
    [img, ~, alpha] = imread('assets/spaceship_HUD.png');

    if ~isempty(alpha)
        img(:, :, 4) = alpha;
    end

    params.spaceship_HUD = Screen('MakeTexture', win, img);
    
    [img, ~, alpha] = imread('assets/startimg_HUD.png');

    if ~isempty(alpha)
        img(:, :, 4) = alpha;
    end
    
    params.startimg_HUD = Screen('MakeTexture', win, img);
end