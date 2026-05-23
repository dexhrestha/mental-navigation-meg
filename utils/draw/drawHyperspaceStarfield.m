function star = drawHyperspaceStarfield(params,move)

    % ------------------------------------------------------------
    % Optional spawn parameters
    % ------------------------------------------------------------
    win = params.ptb.window;
    star = params.star;
    xCenter = params.ptb.xCenter;
    yCenter = params.ptb.yCenter - params.START_Y_PX;
    [screenXpixels, screenYpixels] =   Screen('WindowSize', win);
    
    if nargin < 2 || isempty(move)
        move = 1;
    end

    if ~isfield(star, 'spawnFromHorizontalCenterLine')
        star.spawnFromHorizontalCenterLine = false;
    end

    if ~isfield(star, 'startBandHeight')
        star.startBandHeight = 8;
    end

    if ~isfield(star, 'startXSpread')
        star.startXSpread = star.spaceSize;
    end
    
    % Old z position for streak drawing
    zOld = star.z + star.speed * star.streakLength;
    
    if move
        % Move stars toward viewer
        star.z = star.z - star.speed;
    end
   
    % Reset stars that pass the viewer
    resetIdx = star.z <= star.zMin;
    nReset = sum(resetIdx);

    if nReset > 0

        if star.spawnFromHorizontalCenterLine

            % ----------------------------------------------------
            % Spawn from a horizontal line at the center of screen
            % ----------------------------------------------------
            % x is spread horizontally.
            % y is near 0, so projected sy starts near yCenter.
            % Positive y makes stars enter the lower half of screen.
            %% include the startBand height for the thickness of the line
            star.x(resetIdx) = ...
                (rand(nReset, 1) - 0.5) * star.startXSpread;

            star.y(resetIdx) = ...
                (rand(nReset, 1) - 0.5) * star.spaceSize;

        else

            % ----------------------------------------------------
            % Original behavior:
            % Spawn from a circular / square-ish cloud around center
            % ----------------------------------------------------

            star.x(resetIdx) = ...
                (rand(nReset, 1) - 0.5) * star.spaceSize;

            star.y(resetIdx) = ...
                (rand(nReset, 1) - 0.5) * star.spaceSize ;

        end

        star.z(resetIdx) = star.zMax;

        zOld(resetIdx) = star.zMax + star.speed * star.streakLength;

        star.baseBrightness(resetIdx) = 60 + 95 * rand(nReset, 1);
    end

    % Project 3D positions into 2D screen coordinates
    sx = xCenter + star.focalLength * (star.x ./ star.z);
    sy = yCenter + star.focalLength * (star.y ./ star.z);

    % Previous projected positions for streaks
    sxOld = xCenter + star.focalLength * (star.x ./ zOld);
    syOld = yCenter + star.focalLength * (star.y ./ zOld);

    % Distance from center of screen
    r = sqrt((sx - xCenter) .^ 2 + (sy - yCenter) .^ 2);

    % Only draw stars in lower half of the screen if horizontal center line
    if star.spawnFromHorizontalCenterLine
        screenYpixelsLower = screenYpixels * 0.5;
    else 
        screenYpixelsLower = 0;
    end 
    visible = sx >= 0 & sx <= screenXpixels & ...
              sy >= screenYpixelsLower & sy <= screenYpixels & ...
              r > star.centerDeadZonePx;

    % Fade in away from center
    fade = (r - star.centerDeadZonePx) ./ star.fadeWidthPx;
    fade = max(0, min(fade, 1));

    % Star size increases as stars approach viewer
    starSize = 1 + 5 ./ star.z;
    starSize = max(1, min(starSize, 6));

    % Brightness with fade
    brightness = star.baseBrightness .* fade;
    brightness = max(0, min(brightness, 255));

    % Draw stars
    if star.useStreaks

        for i = 1:star.nStars
            if visible(i)
                Screen('DrawLine', win, ...
                    [brightness(i) brightness(i) brightness(i)], ...
                    sxOld(i), syOld(i), sx(i), sy(i), ...
                    starSize(i));
            end
        end

    else

        dotPositions = [sx(visible)'; sy(visible)'];
        dotSizes = starSize(visible)';
        dotColors = repmat(brightness(visible)', 3, 1);

        Screen('DrawDots', win, ...
            dotPositions, ...
            dotSizes, ...
            dotColors, ...
            [], ...
            2);
    end
end