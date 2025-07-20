function Problema1()
    %disp('DEMO realizzata da: NOME COGNOME, NOME COGNOME');
    
    %% Lettura e allocazione delle immagini

    folder = uigetdir('*.png', 'Selezionare la cartella di immagini da analizzare');
    
    % Controlla se il path assegnato e' valido
    if exist(folder, 'dir') ~= 7
        error('Cartella non trovata: %s', folder);
    end
    
    % Legge e alloca le immagini
    images = dir(fullfile(folder, '*.png'));
    % Controlla se l'allocazione ha avuto successo
    if isempty(images)
        disp('Nessun file png trovato.');
        return; 
    end
    
    %% loop principale
    for i = 1:length(images)
        filename = fullfile(folder, images(i).name);
        img = imread(filename);
        imgInfo = imfinfo(filename);
        imgDim = imgInfo.Width * imgInfo.Height;

        fprintf('\nAnalisi immagine: %s\n', images(i).name);

        % Estrazione feature
        [a, c, xp] = FeaturesExtraction(img);
        
        if isempty(a)
            disp('Nessun oggetto rilevato.');
            continue;
        end
     
        fprintf('Area = %d pixels\nCompatezza = %.2f\nSporgenza = %.2f\n', a, c, xp);
        
        % Classificazione gesti con regole corrette
        gesture = GestureClassification(a, c, xp, imgDim);
        fprintf('Gesto riconosciuto: %s\n', gesture);
    end
end

function [a, c, xp] = FeaturesExtraction(img)
    % Converte l'immagine nella scala di grigi
    % Necessario per la binarizzazione dell'immagine
    grayImg = rgb2gray(img);

    % Binarizzazione dell'immagine
    bwImg = imbinarize(grayImg);

    % Pulizia immagine (apertura e riempimento)
    %img = imopen(img, strel('disk', 3));
    bwImg = imfill(bwImg, 'holes');
    % Estrae l'oggetto piu' grande nell'immagine
    bwImg = bwareafilt(bwImg, 1); 
    
    % Estrae le caratteristiche dell'immagine necessarie per i calcoli
    % successivi
    stats = regionprops(bwImg, 'Area', 'Perimeter', 'BoundingBox', 'Centroid', 'PixelList');
    
    % Controllo se le stastiche non siano vuote
    if isempty(stats)
        a   = 0;
        c   = 0;
        xp  = 0;
        return;
    end

    a = stats.Area;
    p = stats.Perimeter;

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

function gesture = GestureClassification(a, c, xp, imgDim)

    if a < (0.1 * imgDim)
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
