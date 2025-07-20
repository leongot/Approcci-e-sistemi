function Problema5_3()
    %% Lettura e caricamento dei dati
    % Selezione file tramite finestra
    [file, folder] = uigetfile('*.mat', 'Seleziona un file MAT contenente time e var1');

    if isequal(file, 0)
        disp('Operazione annullata dall''utente.');
        return;
    end

    % Caricamento dei dati
    data = load(fullfile(folder, file));

    if ~all(ismember({'time', 'var1'}, fieldnames(data)))
        error('Il file selezionato non contiene le variabili "time" e "var1".');
    end

    %% Inizializzazione dei dati
    time = data.time;
    var1 = data.var1;

    % Verifica consistenza delle dimensioni delle matrici
    if size(time,1) ~= size(var1,1)
        error('Dimensioni incompatibili tra time e matr1.');
    end
    
    %% Ricerca di NaN
    % Ricerca dei NaN in var1
    ind_nan = find(isnan(var1));
    num_nan = numel(ind_nan);
    

    %% Visualizzazione dei risultati
    if num_nan == 0
        fprintf('\n[%s] Nessun NaN rilevato in var1.\n', file);
    else
        fprintf('\n[%s] Rilevati %d valori NaN in var1:\n\n', file, num_nan);

        % Costruzione tabella con indice e timestamp
        T = table( ...
            ind_nan, ...
            time(ind_nan), ...
            'VariableNames', {'Indice', 'Timestamp'} ...
        );

        disp(T);
    end
end


%{
function Problema5_3()
    % Selezione file
    [file, folder] = uigetfile('*.mat', 'Seleziona un file contenente time e var1');
    if isequal(file, 0)
        disp('Operazione annullata dall''utente.');
        return;
    end

    file_path = fullfile(folder, file);
    info = whos('-file', file_path);
    vars = {info.name};

    if ~all(ismember({'time', 'var1'}, vars))
        fprintf('Il file "%s" non contiene entrambe le variabili: time e var1.\n', file);
        return;
    end

    data = load(file_path);
    time = data.time;
    var1 = data.var1;

    % Individua indici NaN
    idx_nan = find(isnan(var1));
    num_nan = numel(idx_nan);

    if num_nan == 0
        fprintf('[%s] Nessun valore NaN rilevato in var1.\n', file);
        return;
    end

    fprintf('[%s] Rilevati %d valori NaN in var1.\n\n', file, num_nan);

    % Analisi sequenze consecutive
    diff_idx = diff(idx_nan);
    boundaries = [0; find(diff_idx > 1); length(idx_nan)];
    
    for i = 1:(length(boundaries)-1)
        start_idx = idx_nan(boundaries(i)+1);
        end_idx = idx_nan(boundaries(i+1));
        count = end_idx - start_idx + 1;

        if count == 1
            fprintf('Valore NaN isolato all''indice %d', start_idx);
        else
            fprintf('%d valori NaN consecutivi tra gli indici %d e %d', count, start_idx, end_idx);
        end

        
        % Se time disponibile, stampa intervallo temporale
        if isdatetime(time)
        if count == 1
            fprintf(' (timestamp: %s)', datestr(time(start_idx)));
        else
            fprintf(' (da %s a %s)', ...
                datestr(time(start_idx)), datestr(time(end_idx)));
        end
    end
    fprintf('\n');

    end
end
%}



