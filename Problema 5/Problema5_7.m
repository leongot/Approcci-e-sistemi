function Problema5_7()

nome_file = input('\nInserisci il nome del file da utilizzare (es. dati3): ', 's');

  if ~endsWith(nome_file, '.mat')
        nome_file = [nome_file '.mat'];
  end

 dati = load(nome_file);

 temp = dati.var1;
 temp = double(temp);
 time = dati.time;
 ora = hour(time);
 giorni = unique(dateshift(time,'start','day'));
 num_giorni = numel(giorni);
 avg_temp = NaN(num_giorni,24);
 min_value = input('Inserisci valore minimo temperatura accettabile: ');
 max_value = input('Inserisci valore massimo temperatura accettabile: ');
 delta_t = seconds(diff(time));
 passo_regolare = [true; delta_t == 60];
 temp_var = diff(temp);
 var_velocity = temp_var ./ delta_t;

 lim_pos = input('Inserisci limite positivo ROC (es. 0.5 °C/s): ');
 lim_neg = input('Inserisci limite negativo ROC (es. -0.5 °C/s): ');
 lim_freezing = input('Inserisci limite minimo per allarme di freezing (es. 0.01 °C/s): ');

not_freezing = [true; abs(var_velocity) < lim_freezing];
valid_velocity = [true; var_velocity < lim_pos & var_velocity > lim_neg];
valid_values = ~isnan(temp) & ~isnat(time) & temp > min_value & temp < max_value...
                          & passo_regolare & valid_velocity & not_freezing;

fprintf('Totale dati: %d\n', numel(temp));
fprintf('Dati validi: %d\n', sum(valid_values));
fprintf('Percentuale validi: %.2f%%\n', 100 * sum(valid_values)/numel(temp));

for g = 1:num_giorni

    current_day = giorni(g);
    indici_giorno = (dateshift(time, 'start', 'day') == current_day);

    for h = 0:23
            indici_ora = (ora == h);
            % seleziona i valori che sono sia nel giorno che nell'ora
            indici_finali = indici_giorno & indici_ora & valid_values;
            % se ci sono dati validi, calcola la media

            if any(indici_finali)
                avg_temp(g, h+1) = round(mean(temp(indici_finali)),2);  % h+1 perché indice MATLAB parte da 1
            end

   end
end

giorni_str = string(giorni);
tabella_risultati = array2table(avg_temp, 'RowNames', giorni_str, ...
    'VariableNames', strcat("h", string(0:23)));
disp(tabella_risultati);
figure;
heatmap( ...
    string(giorni), ...               % Giorni sull'asse X
    string(0:23), ...                 % Ore sull'asse Y
    round(avg_temp', 2), ...          % Trasposizione + arrotondamento a 2 decimali
    'Colormap', parula, ...
    'ColorLimits', [min(avg_temp(:)), max(avg_temp(:))], ...
    'MissingDataColor', [1 1 1], ...  % Colore bianco per i NaN
    'MissingDataLabel', 'Dati mancanti');

title('Temperatura media oraria');
xlabel('Giorno');
ylabel('Ora del giorno');

end
