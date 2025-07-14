function main()
    disp('DEMO realizzata da: NOME COGNOME, NOME COGNOME');
    
    % L'utente deve selezione la cartella dove sono contenute le immagini
    folder = uigetdir('C:\');
    
    % Controlla se il path assegnato e' valido
    if exist(folder, 'dir') ~= 7
        error('Cartella non trovata: %s', folder);
    end
    
    % Legge e alloca le immagini all'interno della cartella assegnata
    images = dir(fullfile(folder, '*.png'));
    % Controlla se l'allocazione ha avuto successo
    if isempty(images)
        disp('Nessun file png trovato.');
        return; 
    end

    % Legge le dimensioni della prima immagine come riferimento per la normalizzazione per normalizzazione (10%)
    % info = imfinfo(fullfile(folder, image(1).name));
    % N = round(info.Height * 0.1);
    % soglia_area = 0.1 * N * (info.Width * 0.1);  % area soglia con dimensioni normalizzate

    for i = 1:length(images)
        filename = fullfile(folder, images(i).name);
        img = imread(filename);
        fprintf('\nAnalisi immagine: %s\n', images(i).name);

        % Estrazione feature
        [a, c, xp] = FeaturesExtraction(img);

        if isempty(a)
            disp('Nessun oggetto rilevato.');
            continue;
        end

        fprintf('Area=%d, Compat=%.2f, Protrusion_ratio=%.2f\n', a, c, xp);
       

        % Classificazione gesti con regole corrette
        gesture = GestureClassification(a, c, xp, img);
        fprintf('Gesto riconosciuto: %s\n', gesture);
    end
end