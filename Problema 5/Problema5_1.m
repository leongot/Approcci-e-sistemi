function Problema5_1()

  disp('DEMO realizzata da: Leonardo Gottani, Nicola Olivieri, Emanuele Bruno');

    % Lettura e caricamento dei dati
    % Selezione file tramite interfaccia
    [file, folder] = uigetfile('*.mat', 'Seleziona un file contenente time e matr1');
    % Controlla se un file e' stato selezionato
    if isequal(file, 0)
        disp('Operazione annullata dall''utente.');
        return;
    end
    % Caricamento dei dati
    data = load(fullfile(folder, file));
    % Controlla la formattazione del file
    if ~all(ismember({'time', 'matr1'}, fieldnames(data)))
        error('Il file selezionato non contiene le variabili "time" e "matr1".');
    end
    
    %% Inizializzazione dei dati
    time  = data.time;
    matr1 = data.matr1;

    % Verifica consistenza delle dimensioni delle matrici
    if size(time,1) ~= size(matr1,1)
        error('Dimensioni incompatibili tra time e matr1.');
    end
    
    %% Input utente
    % Mostra intervallo disponibile
    fprintf('Intervallo disponibile: %s a %s\n', string(time(1)), string(time(end)));
    fprintf('Formato richiesto: gg-MMM-aaaa HH:mm (es. 12-Sep-2023 14:00)\n');
    
    % Vengono utilizzati un serie di loop per assicurasi che l'utente
    % inserisca un valore valido

    % Richiesta timestamp iniziale
    while true
        t_start_str = input('Inserire timestamp iniziale: ', 's');
        try
            t_start = datetime(t_start_str, 'InputFormat', 'dd-MMM-yyyy HH:mm');
            if t_start < time(1) || t_start > time(end)
                fprintf('Data fuori dal range disponibile (%s – %s)\n', ...
                    string(time(1)), string(time(end)));
            else
                break;
            end
        catch
            disp('Formato non valido. Riprova.');
        end
    end

    % Richiesta timestamp finale
    while true
        t_end_str = input('Inserire timestamp finale: ', 's');
        try
            t_end = datetime(t_end_str, 'InputFormat', 'dd-MMM-yyyy HH:mm');
            if t_end < time(1) || t_end > time(end)
                fprintf('Data fuori dal range disponibile (%s – %s)\n', ...
                    string(time(1)), string(time(end)));
            elseif t_end <= t_start
                disp('Il timestamp finale deve essere successivo a quello iniziale.');
            else
                break;
            end
        catch
            disp('Formato non valido. Riprova.');
        end
    end

    % Vengono selezionati gli indici corrispondenti in base ai timestamps
    % selezionati
    idx = time >= t_start & time <= t_end;
    % Utilizzando gli indici si selezionano i valori corrispondenti
    time_selected = time(idx);

    if isempty(time_selected)
        disp('Nessun dato disponibile nell''intervallo selezionato.');
        return;
    end

    % Scelta colonne da visualizzare
    fprintf('Sono disponibili %d sensori (colonne da 1 a %d).\n', size(matr1,2), size(matr1,2));
    cols = input('Inserisci le colonne da visualizzare (es. [1 3]): ', 's');

    while true
        %{
        if strcmpi(cols, 'leave')
            disp('Uscita richiesta. Funzione interrotta.');
            return;
        end
        %}

        cols_num = str2double(cols);
        cols_num = sort(cols_num);
        if isempty(cols_num) || any(cols_num < 1) || any(cols_num > size(matr1,2))
            cols = input('Vettore non valido. Inserisci di nuovo (es. [1 3]): ', 's');
        else
            break;
        end
    end
    
    %% Visualizzazione dei dati
    % Estrazione e visualizzazione dati
    matr_selected = matr1(idx, cols_num);

    % Mostra tabella dei dati
    T = array2table(matr_selected, ...
        'VariableNames', arrayfun(@(c) sprintf('Sensore_%d', c), cols_num, 'UniformOutput', false));
    T.Tempo = time_selected;
    T = movevars(T, 'Tempo', 'Before', 1);

    disp('Dati selezionati:');
    disp(T);
    
    % Visualizzazione del grafico opzionale
    prompt = "Si desidera visualizzare il grafico? S/N: ";
    txt = input(prompt, "s");
    
    if isempty(txt)
        txt = 'N';
    end

    if isequal(txt, 'Y')
        figure;
        plot(time_selected, matr_selected, 'LineWidth', 1.5);
        xlabel('Tempo');
        ylabel('Temperatura [°C]');
        title('Temperature rilevate dai sensori selezionati');
        legend(arrayfun(@(c) sprintf('Sensore %d', c), cols_num, 'UniformOutput', false));
        grid on;
    end   
end
