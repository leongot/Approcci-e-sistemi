function main_gesture_recognition()
    disp('DEMO realizzata da: NOME COGNOME, NOME COGNOME');

    folder = fullfile('C:', 'Users', 'leona', 'Documents', 'MATLAB', 'Approcci e sistemi', 'Problema1', 'Immagini fornite');

    if exist(folder, 'dir') ~= 7
        error('Cartella non trovata: %s', folder);
    end

    files = dir(fullfile(folder, '*.png'));
    if isempty(files)
        disp('Nessun file png trovato.');
        return;
    end

    % Leggi dimensioni immagine originale per normalizzazione (10%)
    info = imfinfo(fullfile(folder, files(1).name));
    N = round(info.Height * 0.1);
    soglia_area = 0.1 * N * (info.Width * 0.1);  % area soglia con dimensioni normalizzate

    for i = 1:length(files)
        filename = fullfile(folder, files(i).name);
        img = imread(filename);
        fprintf('\nAnalisi immagine: %s\n', files(i).name);

        % Estrazione feature
        [area, compat, x_p] = estrai_feature(img, N);

        if isempty(area)
            disp('Nessun oggetto rilevato.');
            continue;
        end

        fprintf('Area=%d, Compat=%.2f, Protrusion_ratio=%.2f\n', area, compat, x_p);

        % Classificazione gesti con regole corrette
        gesto = classifica_gesto(area, compat, x_p, soglia_area);
        fprintf('Gesto riconosciuto: %s\n', gesto);
    end
end

function [area, compat, x_p] = estrai_feature(img, N)
    % Ridimensiona mantenendo proporzioni, altezza a N pixel
    img = imresize(img, [N NaN]);

    if size(img,3) == 3
        img = rgb2gray(img);
    end

    % Binarizzazione e inversione se necessario
    bw = imbinarize(img);
    if mean(bw(:)) > 0.5
        bw = ~bw;
    end

    % Pulizia immagine (apertura e riempimento)
    bw = imopen(bw, strel('disk', 3));
    bw = imfill(bw, 'holes');
    bw = bwareafilt(bw, 1); % Oggetto più grande

    stats = regionprops(bw, 'Area', 'Perimeter', 'BoundingBox', 'Centroid', 'PixelList');

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

    % Compattezza: 4*pi*area / perimetro^2
    compat = 4 * pi * area / (per^2);

    % Calcolo protrusion ratio come da formula
    pixel_list = stats.PixelList; % lista dei pixel dell'oggetto (Nx2: colonne x,y)
    x_coords = pixel_list(:,1);

    x_min = min(x_coords);
    x_max = max(x_coords);
    x_cog = stats.Centroid(1);

    % Protezione contro divisioni per zero
    denom = x_cog - x_min;
    if denom == 0
        x_p = Inf;  % o altro valore arbitrario grande
    else
        x_p = (x_max - x_cog) / denom;
    end
end

function gesto = classifica_gesto(area, compat, x_p, soglia_area)
    if area < soglia_area
        gesto = 'empty';
        return;
    end

    % Regole esatte fornite:
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
