function Problema5_8()
    [file, folder] = uigetfile('*.mat', 'Seleziona un file .mat con time e matr1');
    if isequal(file, 0)
        disp('Operazione annullata.');
        return;
    end

    data = load(fullfile(folder, file));
    if ~isfield(data, 'time') || ~isfield(data, 'matr1')
        error('Il file deve contenere le variabili "time" e "matr1".');
    end

    time = data.time;
    matr1 = data.matr1;

    if size(time,1) ~= size(matr1,1)
        error('Le dimensioni di "time" e "matr1" devono essere compatibili.');
    end

    % Individua righe con almeno un NaN in matr1
    righe_con_nan = any(isnan(matr1), 2);

    % Calcolo media istantanea (ignora NaN)
    media_istantanea = mean(matr1, 2, 'omitnan');

    % Chiedi se usare soglie personalizzate
    usa_custom = input('Vuoi inserire soglie personalizzate? (s/n): ', 's');
    if strcmpi(usa_custom, 's')
        soglia_roc = input('Inserisci soglia per salti anomali (ROC), es. 5: ');
        soglia_freezing = input('Inserisci soglia per freezing, es. 1e-3: ');
    else
        soglia_roc = 5;
        soglia_freezing = 1e-3;
    end

    % Calcolo variazione (ROC) tra istanti
    delta_media = [NaN; diff(media_istantanea)];

    % Inizializzazione segnalazioni
    idx_nan = righe_con_nan;
    idx_roc = abs(delta_media) > soglia_roc;
    idx_roc(isnan(delta_media)) = false; % ignora i NaN
    idx_freeze = abs(delta_media) < soglia_freezing;
    idx_freeze(isnan(delta_media)) = false;
    idx_freezing_blocchi = [false; (idx_freeze(1:end-1) & idx_freeze(2:end))];

    % Tabella risultati
    T = table(time, media_istantanea, 'VariableNames', {'Timestamp', 'Media_Temp'});
    disp('Temperatura media istantanea (aritmetica):');
    disp(T);

    % Segnalazioni testuali
    fprintf('\n--- SEGNALAZIONI ---\n');
    if any(idx_nan)
        fprintf('%d righe con almeno un NaN rilevate in matr1 (evidenziate nel grafico).', sum(idx_nan));
    end
    if any(idx_roc)
        fprintf('%d salti anomali rilevati (>|%.2f| °C).', sum(idx_roc), soglia_roc);
    end
    if any(idx_freezing_blocchi)
        fprintf('%d freezing rilevati (media invariata per almeno 2 istanti).', sum(idx_freezing_blocchi));
    end
    if ~any(idx_nan | idx_roc | idx_freezing_blocchi)
        fprintf('Nessuna anomalia rilevata.');
    end

    % Grafico con segnalazioni
    figure;
    hold on;
    plot(time, media_istantanea, '-k', 'DisplayName', 'Media');

    % NaN
    plot(time(idx_nan), media_istantanea(idx_nan), 'rx', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'NaN (input)');

    % Salti
    plot(time(idx_roc), media_istantanea(idx_roc), 's', 'MarkerSize', 8, ...
        'MarkerEdgeColor', [1 0.5 0], 'LineWidth', 1.5, 'DisplayName', 'Salto');

    % Freezing
    plot(time(idx_freezing_blocchi), media_istantanea(idx_freezing_blocchi), ...
        'bo', 'MarkerSize', 6, 'LineWidth', 1.2, 'DisplayName', 'Freezing');

    xlabel('Tempo');
    ylabel('Temperatura media [°C]');
    title(sprintf('Temperatura media istantanea - %s', file));
    grid on;
    legend('show', 'Location', 'best');
end
