function Problema5_3()

    fprintf('\nDEMO realizzata da: Leonardo Gottani, Nicola Olivieri, Emanuele Bruno\n');
  
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
    
    %% Ricerca di valori NaN
    ind_nan = find(isnan(var1));
    %num_nan = numel(ind_nan);

    %% Visualizzazione dei risultati
    if isempty(ind_nan)
        fprintf('\n[%s] Nessun NaN rilevato.\n', file);
    else
        fprintf('\n[%s] Rilevati %d valori NaN:\n\n', file, numel(ind_nan));

        % Costruzione tabella con indice e timestamp
        T = table( ...
            ind_nan, ...
            time(ind_nan), ...
            'VariableNames', {'Indice', 'Timestamp'} ...
        );

        disp(T);
    end
end





        




