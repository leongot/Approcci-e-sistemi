function Problema5_2()

    fprintf('\nDEMO realizzata da: Leonardo Gottani, Nicola Olivieri, Emanuele Bruno\n');
  
    %% Lettura e caricamento dei dati
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
    
    % Calcolo del delta temporale in secondi
    dt = seconds(diff(time));
    % Ricava il passo di campionamento costante
    ref = mode(dt, 'all');
    
    toll = 1e-6;
    
    %% Ricerca di passi di campionamento non costanti
    % Ricerca di passi di campionamento non costanti
    diff_abs = abs(dt - ref);
    tipo_anomalia = strings(length(dt),1);

    for i=1:length(dt)
        if isnan(dt(i))
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
        fprintf('\n[%s] Passo di campionamento costante: %.6f secondi\n\n', file, ref);
    else
        fprintf('\n[%s] Rilevati passi di campionamento non costanti!\n', file);

        ind_timestamp = anomalie_idx + 1;
        ind_timestamp(ind_timestamp > length(time)) = length(time);

        T = table( ...
            ind_timestamp, ...
            time(ind_timestamp), ...
            dt(anomalie_idx), ...
            diff_abs(anomalie_idx), ...
            tipo_anomalia(anomalie_idx), ...
            'VariableNames', {'Indice time', 'Timestamp', 'Valore', 'Deviazione', 'Tipo'} ...
        );

        disp(T);
    end
end

