function px = deg2px(deg, screenWidthCm, screenWidthPx, viewingDistCm)
% Convert visual degrees to pixels

    cm = 2 * viewingDistCm * tand(deg / 2);
    px = cm * (screenWidthPx / screenWidthCm);
end
