function [px,py] = deg2pix(x_deg, y_deg, screen_width_px,screen_height_px, screen_width_cm,viewing_distance_cm)


    if nargin < 6, viewing_distance_cm = 75;end 
    if nargin < 5, screen_width_cm = 53; end
    if nargin < 4, screen_height_px = 1080; end
    if nargin < 3, screen_width_px = 1920; end

    x_cm = 2 * viewing_distance_cm * tan( deg2rad(x_deg)/2);
    y_cm = 2 * viewing_distance_cm * tan( deg2rad(y_deg)/2);
    
    px = ( x_cm / screen_width_cm + 0.5) * screen_width_px;
    py = ( 0.5 - y_cm / screen_width_cm) * screen_height_px;
end