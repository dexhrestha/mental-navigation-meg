function Bars = create_meg_bars(window, desiredPresentationWidthPx, stimRectSizePx, barColor)
%SETUPSIDEBARS Add left/right black bands and recenter a stimulus rectangle.
%
% Usage (minimal):
%   Bars = SetupSideBars(window, 1440, [rectWidthPx rectHeightPx], [0 0 0]);
%
% Usage (inside a draw loop):
%   Screen('FillRect', window, barColor, Bars.sideBarRects); % draw black bands
%   % Draw your stimuli using Bars.rectCoords or centered on Bars.presentationRect
%
% Inputs:
%   - window: Psychtoolbox window pointer from Screen('OpenWindow', ...)
%   - desiredPresentationWidthPx: width of the "active" presentation strip in pixels.
%       If larger than screen width, it is clamped to the screen width.
%   - stimRectSizePx: [width height] of your stimulus bounding box in pixels.
%   - barColor: [r g b] color for the side bars (use [0 0 0] for black).
%
% Outputs (struct Bars):
%   - screenRect: full window rect [0 0 width height]
%   - presentationRect: centered active strip rect
%   - sideBarRects: 4xN rects for left/right bands (N=2 or 0)
%   - rectCoords: centered stimulus rect within presentationRect
%   - sideBarWidthPx: width of each side band (0 if none)
%
% Notes:
%   - Recenter your stimuli using Bars.rectCoords or Bars.presentationRect.
%   - Draw side bars each frame BEFORE drawing stimuli so they mask the edges.

    % --- Screen geometry ---
    screenRect = Screen('Rect', window);
    screenWidthPx = screenRect(3) - screenRect(1);
    screenHeightPx = screenRect(4) - screenRect(2);

    % --- Clamp desired width and compute bars ---
    presentationWidthPx = min(desiredPresentationWidthPx, screenWidthPx);
    sideBarWidthPx = floor((screenWidthPx - presentationWidthPx) / 2);

    presentationRect = [sideBarWidthPx 0 ...
                        screenWidthPx - sideBarWidthPx ...
                        screenHeightPx];

    if sideBarWidthPx > 0
        sideBarRects = [0 0 sideBarWidthPx screenHeightPx; ...
                        screenWidthPx - sideBarWidthPx 0 screenWidthPx screenHeightPx]';
    else
        sideBarRects = zeros(4, 0);
    end

    % --- Center stimulus rectangle inside presentation strip ---
    [xCenter, yCenter] = RectCenter(presentationRect);
    % rectCoords = [xCenter - stimRectSizePx(1)/2, ...
    %               yCenter - stimRectSizePx(2)/2, ...
    %               xCenter + stimRectSizePx(1)/2, ...
    %               yCenter + stimRectSizePx(2)/2];

    % --- Bundle outputs ---
    Bars.screenRect = screenRect;
    Bars.presentationRect = presentationRect;
    Bars.sideBarRects = sideBarRects;
    % Bars.rectCoords = rectCoords;
    Bars.sideBarWidthPx = sideBarWidthPx;
    Bars.barColor = barColor;
end
