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
 min_value = input('Inserisci valore minimo accettabile');
 max_value = input('Inserisci valore massimo accettabile');
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


for g = 1:num_giorni

    current_day = giorni(g);
    indici_giorno = (dateshift(time, 'start', 'day') == current_day);

    for h = 0:23
            indici_ora = (ora == h);
            % seleziona i valori che sono sia nel giorno che nell'ora
            indici_finali = indici_giorno & indici_ora & valid_values;
            % se ci sono dati validi, calcola la media

            if any(indici_finali)
                avg_temp(g, h+1) = mean(temp(indici_finali));  % h+1 perché indice MATLAB parte da 1
            end

   end
end

giorni_str = string(giorni);
tabella_risultati = array2table(avg_temp, 'RowNames', giorni_str, ...
    'VariableNames', strcat("h", string(0:23)));
disp(tabella_risultati);
figure;
imagesc(avg_temp);
colorbar;
colormap(jet);
xlabel('Ora del giorno');
ylabel('Giorni');
title('Temperatura media oraria');
xticks(1:24); xticklabels(0:23);
yticks(1:num_giorni); yticklabels(giorni_str);

end
