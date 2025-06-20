function main_gesture_recognition()
    % DEMO - Rule-Based Static Gesture Recognition
    disp('DEMO realizzata da: NOME COGNOME, NOME COGNOME');

    folder = 'immagini fornite';  % Cartella immagini
    files = dir(fullfile(folder, '*.png'));  % Puoi cambiare in *.jpg se serve

    if isempty(files)
        disp('Nessuna immagine trovata nella cartella "immagini fornite".');
        return;
    end

    N = 100;  % Dimensione normalizzata
    M = 100;
    soglia_area = 0.1 * N * M;  % 10% della dimensione come soglia minima

    for i = 1:length(files)
        filename = fullfile(folder, files(i).name);
        img = imread(filename);
        fprintf('\nAnalisi immagine: %s\n', files(i).name);

        % Estrazione delle feature
        oggetti = estrai_feature(img, N, M);

        % Classificazione
        gesto = classifica_gesto(oggetti, soglia_area);
        fprintf('Gesto riconosciuto: %s\n', gesto);
    end
end

function oggetti = estrai_feature(img, N, M)
    % Ridimensionamento e conversione in scala di grigi
    img = imresize(img, [N M]);
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Binarizzazione
    bw = imbinarize(img);

    % Inversione automatica se sfondo è nero e mano bianca
    if mean(bw(:)) > 0.5
        bw = ~bw;
    end

    % Pulizia: apertura morfologica e riempimento
    bw = imopen(bw, strel('disk', 3));
    bw = imfill(bw, 'holes');

    % Mantieni solo l'oggetto più grande (probabile mano)
    bw = bwareafilt(bw, 1);

    % Estrazione proprietà
    stats = regionprops(bw, 'Area', 'Centroid', 'Perimeter');
    oggetti = [];

    for i = 1:length(stats)
        a = stats(i).Area;
        per = stats(i).Perimeter;

        if per == 0
            continue;
        end

        c = 4 * pi * a / (per^2);  % Circolarità
        x_p = stats(i).Centroid(1) / M;  % Posizione x normalizzata
        oggetti = [oggetti; a, c, x_p];
    end
end

function gesto = classifica_gesto(oggetti, soglia_area)
    % Filtro: solo oggetti grandi
    oggetti_filtrati = oggetti(oggetti(:,1) >= soglia_area, :);

    if isempty(oggetti_filtrati)
        gesto = 'empty';
        return;
    end

    % Trova oggetto con area massima
    [~, idx_max] = max(oggetti_filtrati(:,1));
    o = oggetti_filtrati(idx_max, :);

    a = o(1);
    c = o(2);
    x_p = o(3);

    % Classificazione basata su regole (slide 86)
    if c < 0.25
        gesto = 'stop';
    elseif x_p > 1.2
        gesto = 'right';
    elseif 1/x_p > 1.2
        gesto = 'left';
    else
        gesto = 'idle';
    end
end
