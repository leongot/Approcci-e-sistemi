function main()
    %disp('DEMO realizzata da: NOME COGNOME, NOME COGNOME');
    
    % L'utente deve selezione la cartella dove sono contenute le immagini
    folder = uigetdir('*.png', 'Selezionare la cartella di immagini da analizzare');
    
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

        fprintf('Area = %d\nCompatezza = %.2f\nSporgenza = %.2f\n', a, c, xp);
        
        % Classificazione gesti con regole corrette
        gesture = GestureClassification(a, c, xp, imgDim);
        fprintf('Gesto riconosciuto: %s\n', gesture);
    end
end