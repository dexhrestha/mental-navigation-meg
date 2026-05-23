function [params] = setup_stars(params) 
    % -------------------------------
    % Hyperspace starfield parameters
    % -------------------------------
    params.star.nStars = 1600;
    params.star.spaceSize = 20;
    params.star.zMax = 20;
    params.star.zMin = 0.15;
    params.star.focalLength = 650;
    params.star.useStreaks = true;
    params.star.streakLength = 1.5;
    params.star.centerDeadZonePx = params.LM_HEIGHT_PX / 2;
    params.star.fadeWidthPx = 8;

    params.star.spawnFromHorizontalCenterLine = true;
    params.star.startBandHeight = 20;
    params.star.startXSpread = 20;



    params.star.speed = 0;

    params.star.x = (rand(params.star.nStars, 1) - 0.5) * params.star.spaceSize;
    params.star.y = (rand(params.star.nStars, 1) - 0.5) * params.star.spaceSize;
    params.star.z = rand(params.star.nStars, 1) * params.star.zMax + params.star.zMin;
    params.star.baseBrightness = 60 + 95 * rand(params.star.nStars, 1);

end