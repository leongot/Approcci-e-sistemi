function Problema5_7_1()
    nome_file = input('\nInserisci il nome del file da utilizzare (es. dati3): ', 's');
    if isempty(nome_file)
        error('Nome del file non può essere vuoto.');
    end

    if ~endsWith(nome_file, '.mat')
        nome_file = [nome_file '.mat'];
    end

    if ~isfile(nome_file)
        error('Il file "%s" non esiste nella directory corrente.', nome_file);
    end

    dati = load(nome_file);
    if ~isfield(dati, 'var1') || ~isfield(dati, 'time')
        error('Il file deve contenere le variabili "var1" e "time".');
    end

    temp = dati.var1;
    time = dati.time;

    if ~isnumeric(temp) || ~isdatetime(time)
        error('"var1" deve essere numerico e "time" deve essere datetime.');
    end

    if numel(temp) ~= numel(time)
        error('Le dimensioni di "var1" e "time" non coincidono.');
    end

    if any(diff(time) < seconds(0))
        warning('I timestamp non sono ordinati. Verranno ordinati.');
        [time, idx] = sort(time);
        temp = temp(idx);
    end

    temp = double(temp);
    ora = hour(time);
    giorni = unique(dateshift(time, 'start', 'day'));
    num_giorni = numel(giorni);
    avg_temp = NaN(num_giorni, 24);

    % === INPUT CON CONTROLLI ===
    min_value = ask_scalar('Inserisci valore minimo temperatura [-100, 100]: ', ...
        @(v) v > -100 && v < 100);
    max_value = ask_scalar(sprintf('Inserisci valore massimo temperatura (>%g e <200): ', min_value), ...
        @(v) v > min_value && v < 200);

    lim_pos = ask_scalar('Inserisci limite positivo ROC (>0): ', @(v) v > 0);
    lim_neg = ask_scalar('Inserisci limite negativo ROC (<0): ', @(v) v < 0);
    lim_freezing = ask_scalar('Inserisci limite freezing (>=0): ', @(v) v >= 0);

    % === CONTROLLO INCROCIATO DEI LIMITI ROC ===
    if lim_freezing > abs(lim_neg)
        warning('Il limite di freezing (%.3f) è maggiore del valore assoluto del limite negativo ROC (%.3f).', ...
            lim_freezing, lim_neg);
    end
    if lim_freezing > lim_pos
        warning('Il limite di freezing (%.3f) è maggiore del limite positivo ROC (%.3f).', ...
            lim_freezing, lim_pos);
    end
    if abs(lim_neg) > lim_pos
        warning('Il limite negativo ROC (%.3f) ha valore assoluto maggiore del limite positivo ROC (%.3f).', ...
            lim_neg, lim_pos);
    end

    % === VALIDAZIONE DATI ===
    delta_t = seconds(diff(time));
    passo_regolare = [true; abs(delta_t - 60) <= 1];  % tolleranza ±1s
    temp_var = diff(temp);
    var_velocity = temp_var ./ delta_t;

    not_freezing = [true; abs(var_velocity) < lim_freezing];
    valid_velocity = [true; var_velocity < lim_pos & var_velocity > lim_neg];
    valid_values = ...
        ~isnan(temp) & ~isnat(time) & ...
        temp > min_value & temp < max_value & ...
        passo_regolare & valid_velocity & not_freezing;

    fprintf('Totale dati: %d\n', numel(temp));
    fprintf('Dati validi: %d\n', sum(valid_values));
    fprintf('Percentuale validi: %.2f%%\n', 100 * sum(valid_values) / numel(temp));

    for g = 1:num_giorni
        current_day = giorni(g);
        indici_giorno = (dateshift(time, 'start', 'day') == current_day);

        for h = 0:23
            indici_ora = (ora == h);
            indici_finali = indici_giorno & indici_ora & valid_values;
            if any(indici_finali)
                avg_temp(g, h+1) = round(mean(temp(indici_finali)), 2);
            end
        end
    end
%tabella command line

   giorni_str = string(giorni);
tabella_risultati = array2table(avg_temp, 'RowNames', giorni_str, ...
    'VariableNames', strcat("h", string(0:23)));
disp(tabella_risultati);

    %heatmap
    figure;
    heatmap( ...
        string(giorni), ...
        string(0:23), ...
        round(avg_temp', 2), ...
        'Colormap', parula, ...
        'ColorLimits', [min(avg_temp(:)), max(avg_temp(:))], ...
        'MissingDataColor', [1 1 1], ...
        'MissingDataLabel', 'Dati mancanti');

    title('Temperatura media oraria');
    xlabel('Giorno');
    ylabel('Ora del giorno');
end

% === FUNZIONE DI SUPPORTO PER INPUT CONVALIDATO ===
function val = ask_scalar(prompt, validator)
    tentativi = 0;
    max_tentativi = 5;
    while true
        val = input(prompt);
        tentativi = tentativi + 1;
        if isempty(val) || ~isnumeric(val) || ~isscalar(val) || ~validator(val)
            fprintf(2, '↺ Input non valido. Riprova.\n');
            if tentativi >= max_tentativi
                error('Troppe risposte errate. Esecuzione interrotta.');
            end
        else
            break;
        end
    end
end