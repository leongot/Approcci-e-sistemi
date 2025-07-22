function Problema5_6()

    fprintf('\nDEMO realizzata da: Leonardo Gottani, Nicola Olivieri, Emanuele Bruno\n');
    
    %% Lettura e caricamento dei dati
    [file, folder] = uigetfile('*.mat', 'Selezione un file .mat con time e var1.');

    if isequal(file, 0)
        disp('Operazione annullata.');
        return
    end

    data = load(fullfile(folder, file));

    if (~isfield(data, 'time') || ~isfield(data, 'var1'))
        error('Il file deve contenere i campi "time" e "var1".');
    end
    
    %% Inizializzazione dei dati
    time = data.time;
    var1 = data.var1;
    
    dt  = seconds(diff(time));
    dv  = diff(var1);
    ROC = dv ./ dt;
    
    %% Rilevamento di eventi di freezing
    freezingLimit = input('Inserire il limite per allarme di freezing: ');

    warnings = strings(length(ROC), 1);

    for i = 1:length(ROC)
        currROC = ROC(i);
        if abs(currROC) < freezingLimit
            warnings(i) = "Freezing";
        end
    end
    
    %% Visualizzazione dei risultati
    warningsId = find(warnings ~= "");
    
    if isempty(warningsId)
        disp('Nessun allarme freezing rilevato.');
    else
        T = table(warningsId, time(warningsId), warnings(warningsId), ...
            'VariableNames' , {'Indice', 'Timestamp', 'Allarme'});
        disp('Eventi freezing rilevati:');
        disp(T);
    end

    % Grafico opzionale
    
    prompt = "Si desidera visualizzare il grafico? S/N: ";
    txt = input(prompt, "s");
    
    if isempty(txt) || ~isequal(txt, 'N') || ~isequal(txt, 'S')
        txt = 'N';
    end

    if isequal(txt, 'S')
        figure;
        plot(time(2:end), ROC, '-k'); hold on;
        
        % Segnalo freezing rilevati
        plot(time(warningsId + 1), ROC(warningsId), 'bo', 'MarkerFaceColor', 'b');
        
        % Aggiungo linee di riferimento per i limiti freezing
        yline(freezingLimit, '--r', 'Limite Freezing (+)');
        yline(-freezingLimit, '--r', 'Limite Freezing (-)');
        
        xlabel('Tempo'); ylabel('ROC [°C/s]');
        title('Rate of Change e Freezing'); 
        grid on;
        legend('ROC', 'Freezing rilevati', 'Limiti freezing');
    end
end
