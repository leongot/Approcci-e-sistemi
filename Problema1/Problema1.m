function main_gesture_recognition()
    disp('DEMO realizzata da: NOME COGNOME, NOME COGNOME');

    folder = uigetdir('C:\');

    if exist(folder, 'dir') ~= 7
        error('Cartella non trovata: %s', folder);
    end

    files = dir(fullfile(folder, '*.png'));
    if isempty(files)
        disp('Nessun file PNG trovato.');
        return;
    end

    for i = 1:length(files)
        filename = fullfile(folder, files(i).name);
        img = imread(filename);
        fprintf('\nAnalisi immagine: %s\n', files(i).name);

        % Calcola N per questa immagine (10% dell'altezza originale)
        N = round(size(img, 1) * 0.1);

        % Ridimensiona l'immagine per calcolare la soglia
        img_resized = imresize(img, [N NaN]);         % ridimensiona in altezza a N, mantieni proporzioni
        [~, new_width] = size(rgb2gray(img_resized)); % larghezza dell'immagine ridotta (in scala di grigi)
        soglia_area = 0.1 * N * new_width;            % calcolo soglia area

        % Estrai le feature usando immagine originale ma ridimensionata internamente
        [area, compat, x_p] = estrai_feature(img, N);

        if isempty(area)
            disp('Nessun oggetto rilevato.');
            continue;
        end

        fprintf('Area = %d, Compat = %.2f, Protrusion_ratio = %.2f\n', area, compat, x_p);

        % Classifica gesto
        gesto = classifica_gesto(area, compat, x_p, soglia_area);
        fprintf('Gesto riconosciuto: %s\n', gesto);
    end
end

function [area, compat, x_p] = estrai_feature(img, N)
    % Ridimensiona immagine per elaborazione
    img = imresize(img, [N NaN]);

    % Converti in grayscale se RGB
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Binarizzazione
    bw = imbinarize(img);
    if mean(bw(:)) > 0.5
        bw = ~bw;
    end

    % Pulizia morfologica
    bw = imopen(bw, strel('disk', 3));
    bw = imfill(bw, 'holes');
    bw = bwareafilt(bw, 1); % Prendi l'oggetto più grande

    stats = regionprops(bw, 'Area', 'Perimeter', 'Centroid', 'PixelList');

    if isempty(stats)
        area = [];
        compat = [];
        x_p = [];
        return;
    end

    area = stats.Area;
    per = stats.Perimeter;

    if per == 0
        area = [];
        compat = [];
        x_p = [];
        return;
    end

    % Compattezza
    compat = 4 * pi * area / (per^2);

    % Protrusion ratio
    x_coords = stats.PixelList(:,1);
    x_min = min(x_coords);
    x_max = max(x_coords);
    x_cog = stats.Centroid(1);

    denom = x_cog - x_min;
    if denom == 0
        x_p = Inf;
    else
        x_p = (x_max - x_cog) / denom;
    end
end

function gesto = classifica_gesto(area, compat, x_p, soglia_area)
    if area < soglia_area
        gesto = 'empty';
        return;
    end

    if compat < 0.25
        gesto = 'stop';
    elseif x_p > 1.2
        gesto = 'right';
    elseif 1/x_p > 1.2
        gesto = 'left';
    else
        gesto = 'idle';
    end
end