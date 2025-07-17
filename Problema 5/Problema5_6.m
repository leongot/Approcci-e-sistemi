function Problema5_6()
    [file, folder] = uigetfile('*.mat', 'Selezione un file .mat con time e var1.');
    if isequal(file, 0)
        disp('Operazione annullata.');
        return
    end

    data = load(fullfile(folder, file));
    if (~isfield(data, 'time') || ~isfield(data, 'var1'))
        error('Il file deve contenere i campi "time" e "var1".');
    end

    time = data.time;
    var1 = data.var1;
    dt  = seconds(diff(time));
    dv  = diff(var1);
    ROC = dv ./ dt;

    freezingLimit = input('Inserire il limite per allarme di freezing: ');
    warnings = strings(length(ROC), 1);

    for i = 1:length(ROC)
        currROC = ROC(i);
        if abs(currROC) < freezingLimit
            warnings(i) = "Freezing";
        end
    end

    warningsId = find(warnings ~= "");
    if isempty(warningsId)
        disp('Nessun allarme freezing rilevato.');
    else
        T = table(warningsId, time(warningsId), warnings(warningsId), ...
            'VariableNames' , {'Indice', 'Timestamp', 'Allarme'});
        disp('Eventi freezing rilevati:');
        disp(T);
    end

    % Grafico
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



    % Test anche con dati3.mat
    try
        [d3_var1, d3_time] = carica_var1_con_path('dati3.mat');
    catch ME
        fprintf('Errore nel caricamento di dati3.mat: %s\n', ME.message);
        return;
    end

    dt3 = seconds(diff(d3_time));
    dv3 = diff(d3_var1);
    ROC3 = dv3 ./ dt3;

    warnings3 = strings(length(ROC3), 1);
    for i = 1:length(ROC3)
        if ROC3(i) < freezingLimit
            warnings3(i) = "Freezing";
        end
    end

    id3 = find(warnings3 ~= "");
    if isempty(id3)
        disp('[dati3.mat] Nessun allarme freezing rilevato.');
    else
        T3 = table(id3, d3_time(id3), warnings3(id3), ...
            'VariableNames', {'Indice', 'Timestamp', 'Allarme'});
        disp('[dati3.mat] Eventi freezing rilevati:');
        disp(T3);
    end
end

function [var1, time] = carica_var1_con_path(nome_file)
    if isfile(nome_file)
        data = load(nome_file);
    else
        files = dir(fullfile(pwd, '**', nome_file));
        if isempty(files)
            error('File "%s" non trovato.', nome_file);
        end
        data = load(fullfile(files(1).folder, files(1).name));
    end

    if ~isfield(data, 'var1') || ~isfield(data, 'time')
        error('Il file "%s" deve contenere "var1" e "time".', nome_file);
    end

    var1 = data.var1;
    time = data.time;
end
