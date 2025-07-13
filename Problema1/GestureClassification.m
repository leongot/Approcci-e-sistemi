function gesture = GestureClassification(a, c, xp, img)
    if a < (img.height * img.width)
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
