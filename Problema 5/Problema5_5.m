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
    velocita = dv ./ dt;           % velocità di variazione

    % Chiedi limiti all’utente
    limite_pos = input('Inserisci limite positivo ROC (es. 0.5 °C/s): ');
    limite_neg = input('Inserisci limite negativo ROC (es. -0.5 °C/s): ');
    limite_freezing = input('Inserisci limite minimo per allarme di freezing (es. 0.01 °C/s): ');

    % Inizializzazione classificazione
    tipo_allarme = strings(length(velocita), 1);

    for i = 1:length(velocita)
        v = velocita(i);
        if isnan(v) || ~isfinite(v)
            tipo_allarme(i) = "Dato non valido";
        elseif v > limite_pos
            tipo_allarme(i) = "ROC positivo";
        elseif v < limite_neg
            tipo_allarme(i) = "ROC negativo";
        elseif abs(v) < limite_freezing
            tipo_allarme(i) = "Freezing";
        else
            tipo_allarme(i) = "";
        end
    end

    idx_allarmi = find(tipo_allarme ~= "");

    if isempty(idx_allarmi)
        fprintf('Nessun allarme rilevato.\n');
    else
        T = table( ...
            idx_allarmi + 1, ...
            time(idx_allarmi + 1), ...
            velocita(idx_allarmi), ...
            tipo_allarme(idx_allarmi), ...
            'VariableNames', {'Indice', 'Timestamp', 'Velocita', 'Tipo_Allarme'} ...
        );
        disp('Eventi di allarme rilevati:');
        disp(T);
    end

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
end
