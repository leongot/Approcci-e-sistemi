function main_gesture_recognition()
    disp(['Current folder: ', pwd]);
    disp('DEMO realizzata da: NOME COGNOME, NOME COGNOME');

    % Percorso cartella immagini - modifica se serve
    folder = fullfile('C:', 'Users', 'leona', 'Documents', 'MATLAB', ...
                      'Approcci e sistemi', 'Problema 1', 'Immaginifornite');

    if exist(folder, 'dir') ~= 7
        error('Cartella non trovata: %s', folder);
    end

    files = dir(fullfile(folder, '*.png'));
    if isempty(files)
        disp('Nessun file png trovato.');
        return;
    else
        disp('File trovati:');
        for k = 1:length(files)
            disp(files(k).name);
        end
    end

    N = 100;  % dimensione altezza normalizzata
    M = 100;  % dimensione larghezza normalizzata
    soglia_area = 0.1 * N * M;  % 10% area minima per oggetto

    for i = 1:length(files)
        filename = fullfile(folder, files(i).name);
        img = imread(filename);
        fprintf('\nAnalisi immagine: %s\n', files(i).name);

        % Estrazione feature: area, compattezza, protrusion ratio
        oggetti = estrai_feature(img, N, M);

        if isempty(oggetti)
            fprintf('Nessun oggetto rilevato.\n');
            continue;
        end

        % Classificazione gesto tramite regole
        gesto = classifica_gesto(oggetti, soglia_area);
        fprintf('Gesto riconosciuto: %s\n', gesto);
    end
end

function oggetti = estrai_feature(img, N, M)
    % Ridimensiona immagine a NxM e converte in scala di grigi
    img = imresize(img, [N M]);
    if size(img,3) == 3
        img = rgb2gray(img);
    end

    % Binarizzazione automatica (soglia adattiva)
    bw = imbinarize(img);

    % Inverte binarizzazione se sfondo nero (media > 0.5)
    if mean(bw(:)) > 0.5
        bw = ~bw;
    end

    % Pulizia: apertura morfologica e riempimento buchi
    bw = imopen(bw, strel('disk',3));
    bw = imfill(bw, 'holes');

    % Mantieni solo l’oggetto più grande (presumibilmente la mano)
    bw = bwareafilt(bw, 1);

    % Calcola proprietà dell’oggetto
    stats = regionprops(bw, 'Area', 'Perimeter');

    if isempty(stats)
        oggetti = [];
        return;
    end

    % Estrai contorno per calcolare protrusion ratio
    contorni = bwboundaries(bw);
    if isempty(contorni)
        protrusion_ratio = 0;
    else
        boundary = contorni{1};
        min_x = min(boundary(:,2));
        max_x = max(boundary(:,2));
        protrusion_ratio = (max_x - min_x) / M;  % Normalizzato larghezza oggetto
    end

    oggetti = [];
    for i = 1:length(stats)
        a = stats(i).Area;          % Area pixel oggetto
        per = stats(i).Perimeter;  % Perimetro oggetto

        if per == 0
            continue;
        end

        % Compattezza (circolarità):
        % c = 4*pi*Area / Perimetro^2
        % c = 1 per cerchio perfetto, <1 altrimenti
        c = 4 * pi * a / (per^2);

        % Salvo vettore feature: [area, compattezza, protrusion_ratio]
        oggetti = [oggetti; a, c, protrusion_ratio];

        % Stampa di debug
        fprintf('Area=%d, Circularity=%.2f, Protrusion_ratio=%.2f\n', a, c, protrusion_ratio);
    end
end

function gesto = classifica_gesto(oggetti, soglia_area)
    % Filtra oggetti con area maggiore o uguale alla soglia minima
    oggetti_filtrati = oggetti(oggetti(:,1) >= soglia_area, :);

    if isempty(oggetti_filtrati)
        gesto = 'empty';
        return;
    end

    % Seleziona oggetto con area massima
    [~, idx_max] = max(oggetti_filtrati(:,1));
    o = oggetti_filtrati(idx_max, :);

    a = o(1);     % Area
    c = o(2);     % Compatattezza (circolarità)
    x_p = o(3);   % Protrusion ratio

    % Regole di classificazione basate sulle features:
    % - Se compattezza molto bassa => 'stop' (mano aperta o molto irregolare)
    % - Se protrusion ratio alto (>0.44) => mano a destra (right)
    % - Se protrusion ratio basso (<0.40) => mano a sinistra (left)
    % - Altrimenti => 'idle' (riposo o gesto neutro)

    if c < 0.25
        gesto = 'stop';
    elseif x_p > 0.44
        gesto = 'right';
    elseif x_p < 0.40
        gesto = 'left';
    else
        gesto = 'idle';
    end
end
