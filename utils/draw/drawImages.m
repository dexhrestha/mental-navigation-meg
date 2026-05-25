
function drawImages(win, params, currPos, spacingPx, xCenter, yPos, n)

    for k = 1:n

        if isfield(params, 'CENTRAL') && params.CENTRAL
            xPos = xCenter;
        else
            xPos = xCenter + currPos(k);
        end

        dstRect = CenterRectOnPointd( ...
            [0 0 params.LM_WIDTH_PX params.LM_HEIGHT_PX], ...
            xPos, yPos);

        currImgId = params.trial(params.trialId).imgArrShifted(k);
        nCats = size(params.tex, 1);
        nCatImgs = size(params.tex, 2);
        
        currCatImgId = mod(currImgId - 1, nCatImgs) + 1;
        currCatId = mod(floor((currImgId - 1) / nCatImgs), nCats) + 1;

        curTex = params.tex{currCatId, currCatImgId};
        
        dist = abs(currPos(k));

        fadeRadius = spacingPx;
        alpha01 = 1 - min(dist / fadeRadius, 1);
        alpha01 = alpha01 .^ 6;
        alpha = round(255 * alpha01);

        if alpha > 0
            Screen('DrawTexture', win, curTex, [], dstRect, [], [], [], ...
                [255 255 255 alpha]);

            drawImgHUD(params);
        end
    end
end

