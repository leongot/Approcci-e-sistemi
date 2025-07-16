function Problema5_5()

    [file, folder] = uigetfile('*.mat', 'Seleziona un file .mat con time e var1');
    if isequal(file, 0)
        disp('Operazione annullata.');
        return;
    end
    
    data = load(fullfile(folder, file));
    if ~isfield(data, 'time') || ~isfield(data, 'var1')
        error('Il file deve contenere le variabili "time" e "var1".');
    end
    
    time = data.time;
    var1 = data.var1;

    % Calcolo velocità di variazione
    dt = seconds(diff(time));      % tempo in secondi
    dv = diff(var1);               % variazione var1
    ROC = dv ./ dt;           % velocità di variazione

    % Chiedi limiti all’utente
    ROCPositiveLim = input('Inserisci limite positivo ROC (es. 0.5 °C/s): ');
    ROCNegativeLim = input('Inserisci limite negativo ROC (es. -0.5 °C/s): ');
    %limite_freezing = input('Inserisci limite minimo per allarme di freezing (es. 0.01 °C/s): ');

    % Inizializzazione classificazione
    warnings = strings(length(ROC), 1);

    for i = 1:length(ROC)
        currROC = ROC(i);
        if isnan(currROC) || ~isfinite(currROC)
            warnings(i) = "Dato non valido";
        elseif currROC > ROCPositiveLim
            warnings(i) = "ROC positivo";
        elseif currROC < ROCNegativeLim
            warnings(i) = "ROC negativo";
        else
            warnings(i) = "";
        end
    end

    warningsId = find(warnings ~= "", 1);

    if isempty(warningsId)
        fprintf('Nessun allarme rilevato.\n');
    else
        T = table( ...
            warningsId + 1, ...
            time(warningsId + 1), ...
            ROC(warningsId), ...
            warnings(warningsId), ...
            'VariableNames', {'Indice', 'Timestamp', 'ROC', 'Tipo_Allarme'} ...
        );
        disp('Eventi di allarme rilevati:');
        disp(T);
    end

    %{
    % (Opzionale) Plot
    figure;
    plot(time(2:end), velocita, 'k'); hold on;
    yline(limite_pos, '--r', 'Limite +'); 
    yline(limite_neg, '--b', 'Limite -');
    yline(limite_freezing, ':g', 'Freezing');
    yline(-limite_freezing, ':g');
    xlabel('Tempo'); ylabel('Velocità [°C/s]');
    title('Variazione di var1 e allarmi ROC / Freezing');
    grid on;
    %}

    fileName = fileparts(file);

    if ~isequal(fileName, 'dati3.mat')
        data3 = load(fullfile(folder, 'dati3.mat'));
        
        d3_var1 = data3.var1;
       
    d3_dv = diff(d3_var1);

        d3_dmax = max(d3_dv);
        d3_dmin = min(d3_dv);
        
        d3_warnings = strings(length(ROC), 1);

        for i = 1:length(ROC)
            currROC = ROC(i);
            if isnan(currROC) || ~isfinite(currROC)
                d3_warnings(i) = "Dato non valido";
            elseif currROC > d3_dmax
                d3_warnings(i) = "ROC positivo";
            elseif currROC < d3_dmin
                d3_warnings(i) = "ROC negativo";
            else
                d3_warnings(i) = "";
            end
        end

        d3_warningsId = find(d3_warnings ~= "", 1);
        
        if isempty(d3_warningsId)
            fprintf('Nessun allarme rilevato.\n');
        else
            T = table( ...
                d3_warningsId + 1, ...
                time(d3_warningsId + 1), ...
                ROC(d3_warningsId), ...
                d3_warnings(d3_warningsId), ...
                'VariableNames', {'Indice', 'Timestamp', 'ROC', 'Tipo_Allarme'} ...
            );
            disp('Eventi di allarme rilevati utilizzando dati da dati3.mat:');
            disp(T);
        end
    else
        return;
    end
end
