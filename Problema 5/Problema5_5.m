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

    dt = seconds(diff(time));
    dv = diff(var1);
    ROC = dv ./ dt;

    positiveLim = input('Inserisci limite positivo ROC (es. 0.5 °C/s): ');
    negativeLim = input('Inserisci limite negativo ROC (es. -0.5 °C/s): ');

    tipi_allarme = strings(length(ROC), 1);
    for i = 1:length(ROC)
        val = ROC(i);
        if isnan(val) || ~isfinite(val)
            tipi_allarme(i) = "Dato non valido";
        elseif val > positiveLim
            tipi_allarme(i) = "ROC positivo";
        elseif val < negativeLim
            tipi_allarme(i) = "ROC negativo";
        end
    end

    id_allarme = find(tipi_allarme ~= "");
    if isempty(id_allarme)
        disp('Nessun allarme rilevato.');
    else
        T = table(id_allarme + 1, time(id_allarme + 1), ROC(id_allarme), tipi_allarme(id_allarme), ...
            'VariableNames', {'Indice', 'Timestamp', 'ROC', 'Tipo_Allarme'});
        disp('Eventi di allarme rilevati:');
        disp(T);
    end

    % Grafico
    figure;
    plot(time(2:end), ROC, '-k'); hold on;
    plot(time(id_allarme + 1), ROC(id_allarme), 'ro', 'MarkerFaceColor', 'r');
    xlabel('Tempo'); ylabel('ROC [°C/s]');
    title('Rate of Change e Allarmi'); grid on;
    legend('ROC', 'Allarmi rilevati');

    % Test anche con dati3.mat
    try
        [d3_var1, ~] = carica_var1_con_path('dati3.mat');
    catch ME
        fprintf('Errore nel caricamento di dati3.mat: %s\n', ME.message);
        return;
    end

    d3_dv = diff(d3_var1);
    d3_dmax = max(d3_dv);
    d3_dmin = min(d3_dv);

    d3_allarmi = strings(length(ROC), 1);
    for i = 1:length(ROC)
        val = ROC(i);
        if isnan(val) || ~isfinite(val)
            d3_allarmi(i) = "Dato non valido";
        elseif val > d3_dmax
            d3_allarmi(i) = "ROC positivo";
        elseif val < d3_dmin
            d3_allarmi(i) = "ROC negativo";
        end
    end

    id_d3 = find(d3_allarmi ~= "");
    if isempty(id_d3)
        disp('Nessun allarme rilevato (con limiti dati3.mat).');
    else
        T3 = table(id_d3 + 1, time(id_d3 + 1), ROC(id_d3), d3_allarmi(id_d3), ...
            'VariableNames', {'Indice', 'Timestamp', 'ROC', 'Tipo_Allarme'});
        disp('Eventi di allarme rilevati (limiti da dati3.mat):');
        disp(T3);

        % Grafico aggiuntivo per confronto
        plot(time(id_d3 + 1), ROC(id_d3), 'bs', 'MarkerFaceColor', 'b');
        legend('ROC', 'Allarmi rilevati', 'Allarmi da dati3.mat');
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
