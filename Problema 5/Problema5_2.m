function Problema5_2()

  disp('DEMO realizzata da: Leonardo Gottani, Nicola Olivieri, Emanuele Bruno');
  
    % Lettura e caricamento dei dati
    % Selezione file tramite finestra
    [file, folder] = uigetfile('*.mat', 'Seleziona un file contenente time e var1');
    % Controlla se un file e' stato selezionato
    if isequal(file, 0)
        disp('Operazione annullata dall''utente.');
        return;
    end
    
    % Caricamento dei dati
    data = load(fullfile(folder, file));

    if ~all(ismember({'time', 'var1'}, fieldnames(data)))
        error('Il file selezionato non contiene le variabili "time" e "var1".');
    end
    
     % Inizializzazione dei dati
    time = data.time; % Nel caso di questo problema solo il tempo e' di interesse

    % Calcolo del delta temporale
    dt = diff(time);
    % Conversione in secondi per facilitare i calcoli
    dt_seconds = seconds(dt);
    % Ricava il passo di campionamento costante
    ref = mode(dt_seconds, 'all');
    
    toll = 1e-6;

    % Ricerca di passi di campionamento non costanti
    %ref = scegli_passo_riferimento(dt_seconds, toll);
    diff_abs = abs(dt_seconds - ref);
    tipo_anomalia = strings(length(dt_seconds),1);

    for i=1:length(dt_seconds)
        if isnan(dt_seconds(i))
            tipo_anomalia(i) = "NaT/NaN";
        elseif diff_abs(i) > toll
            tipo_anomalia(i) = "Deviazione";
        else
            tipo_anomalia(i) = "";
        end
    end

    anomalie_idx = find(tipo_anomalia ~= "");
    
    %% Visualizzazione dei risultati
    if isempty(anomalie_idx)
        fprintf('[%s] Passo di campionamento costante: %.6f secondi\n\n', file, ref);
    else
        fprintf('[%s] Passo di campionamento NON costante!\n', file);

        ind_timestamp = anomalie_idx + 1;
        ind_timestamp(ind_timestamp > length(time)) = length(time);

        T = table( ...
            ind_timestamp, ...
            time(ind_timestamp), ...
            dt_seconds(anomalie_idx), ...
            diff_abs(anomalie_idx), ...
            tipo_anomalia(anomalie_idx), ...
            'VariableNames', {'Indice time', 'Timestamp', 'Valore', 'Deviazione', 'Tipo'} ...
        );

        disp(T);
    end
end

