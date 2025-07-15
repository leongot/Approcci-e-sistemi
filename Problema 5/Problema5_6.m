function Problema5_6()
    % Chiede all'
    [file, folder] = uigetfile('*.mat', 'Selezione un file .mat con time e var1.');
    
    % L'utente non ha selezionato nessun file
    if isequal(file, 0)
        disp('Operazione annullata.');
        return
    end
    
    data = load(fullfile(folder, file));
    
    % Controlla che i dati caricati contengano i campi corretti
    if (~isfield(data, 'time') || ~isfield(data, 'var1'))
        error('Il file deve contenere i campi "time" e "var1".');
    end

    time = data.time;
    var1 = data.var1;
    
    % Calcola la velocita' di variazione
    dt  = seconds(diff(time));
    dv  = diff(var1);
    ROC = dv ./ dt;

    freezingLimit = input('Inserire il limite per allarme di freezing: ');

    warnings = strings(length(ROC), 1);

    for i = 1:length(ROC)
        currROC = ROC(i);
        if currROC < freezingLimit
            warnings(i) = "Freezing";
        else 
            warnings(i) = "";
        end
    end

    warningsId = find(warnings ~= "");

    if isempty(warningsId)
        disp('Nessum allarme rilevato.')
    else
        T = table( ...
            warningsId, ...
            time(warningsId), ...
            warnings(warningsId), ...
            'VariableNames' , {'Indice', 'Timestamp', 'Allarme'} ...
        );
        disp('Eventi freezing rilevati:');
        disp(T);
    end
end

