function Problema5_1()
    % Selezione file tramite interfaccia
    [file, folder] = uigetfile('*.mat', 'Seleziona un file contenente time e matr1');
    if isequal(file, 0)
        disp('Operazione annullata dall''utente.');
        return;
    end

    data = load(fullfile(folder, file));

    if ~all(ismember({'time', 'matr1'}, fieldnames(data)))
        error('Il file selezionato non contiene le variabili "time" e "matr1".');
    end

    time = data.time;
    matr1 = data.matr1;

    % Verifica consistenza
    if size(time,1) ~= size(matr1,1)
        error('Dimensioni incompatibili tra time e matr1.');
    end

    % Mostra intervallo disponibile
    fprintf('Intervallo disponibile: %s a %s\n', string(time(1)), string(time(end)));
    fprintf('Formato richiesto: gg-MMM-aaaa HH:mm (es. 12-Sep-2023 14:00)\n');

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

    % Selezione intervallo di tempo
    idx = time >= t_start & time <= t_end;
    time_selected = time(idx);

    % Scelta colonne
    fprintf('Sono disponibili %d sensori (colonne da 1 a %d).\n', size(matr1,2), size(matr1,2));
    cols = input('Inserisci le colonne da visualizzare (es. [1 3] oppure "leave" per uscire): ', 's');

    while true
        if strcmpi(cols, 'leave')
            disp('Uscita richiesta. Funzione interrotta.');
            return;
        end

        cols_num = str2num(cols); %#ok<ST2NM>
        if isempty(cols_num) || any(cols_num < 1) || any(cols_num > size(matr1,2))
            cols = input('Vettore non valido. Inserisci di nuovo (es. [1 3] oppure "leave"): ', 's');
        else
            break;
        end
    end

    % Estrazione e visualizzazione dati
    matr_selected = matr1(idx, cols_num);

    % Mostra tabella dei dati
    T = array2table(matr_selected, ...
        'VariableNames', arrayfun(@(c) sprintf('Sensore_%d', c), cols_num, 'UniformOutput', false));
    T.Tempo = time_selected;
    T = movevars(T, 'Tempo', 'Before', 1);

    disp('Dati selezionati:');
    disp(T);

    % (Opzionale) Mostra grafico
    figure;
    plot(time_selected, matr_selected, 'LineWidth', 1.5);
    xlabel('Tempo');
    ylabel('Temperatura [°C]');
    title('Temperature rilevate dai sensori selezionati');
    legend(arrayfun(@(c) sprintf('Sensore %d', c), cols_num, 'UniformOutput', false));
    grid on;
end
