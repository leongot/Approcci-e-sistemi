function gesture = GestureClassification(a, c, xp, img)
    
    imgInfo = imfinfo(fullfile(img.name));

    if a < (imgInfo.height * imgInfo.width)
        gesture = 'empty';
        return;
    end

    if c < 0.25
        gesture = 'stop';
    elseif xp > 1.2
        gesture = 'right';
    elseif 1/xp > 1.2
        gesture = 'left';
    else
        gesture = 'idle';
    end
end
