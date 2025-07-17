function [a, c, xp] = FeaturesExtraction(img)
    % Ridimensiona mantenendo proporzioni, altezza a N pixel
    %img = imresize(img, [N NaN]);

    %if size(img,3) == 3 % ?
    %    img = rgb2gray(img);
    %end
    
    % Converte l'immagine nella scale di grigi
    % Necessario per la binarizzazione dell'immagine
    grayImg = rgb2gray(img);

    % Binarizzazione e inversione se necessario
    bwImg = imbinarize(grayImg);

    %if mean(bw(:)) > 0.5
    %    bw = ~bw;
    %end

    % Pulizia immagine (apertura e riempimento)
    %img = imopen(img, strel('disk', 3));
    bwImg = imfill(bwImg, 'holes');
    % Estae l'oggetto piu' grande nell'immagine
    bwImg = bwareafilt(bwImg, 1); 

    stats = regionprops(bwImg, 'Area', 'Perimeter', 'BoundingBox', 'Centroid', 'PixelList');

    if isempty(stats)
        a   = 0;
        c   = 0;
        xp  = 0;
        return;
    end

    a = stats.Area;
    p = stats.Perimeter;

    if p == 0
        a   = 0;
        c   = 0;
        xp  = 0;
        return;
    end

    % Calcolo compatezza
    c = 4 * pi * a / (p^2);

    % Calcolo protrusion ratio
    pixelList = stats.PixelList;
    
    xCoords = pixelList(:,1);
    xMin = min(xCoords);
    xMax = max(xCoords);
    xCog = stats.Centroid(1);

    denom = xCog - xMin;
    if denom == 0 % Protezione contro divisioni per zero
        xp = Inf; 
    else
        xp = (xMax - xCog) / denom;
    end
end