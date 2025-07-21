function Problema5_3()

  disp('DEMO realizzata da: Leonardo Gottani, Nicola Olivieri, Emanuele Bruno');
  
    % Lettura e caricamento dei dati
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

    % Inizializzazione dei dati
    time = data.time;
    var1 = data.var1;

    % Verifica consistenza delle dimensioni delle matrici
    if size(time,1) ~= size(var1,1)
        error('Dimensioni incompatibili tra time e matr1.');
    end
    
    % Ricerca di NaN
    % Ricerca dei NaN in var1
    ind_nan = find(isnan(var1));
    num_nan = numel(ind_nan);
    

    % Visualizzazione dei risultati
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





        




