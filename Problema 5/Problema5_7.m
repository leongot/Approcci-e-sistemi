function Problema5_7()
    
    %% Lettura del file
    %------------------
    [file, folder] = uigetfile('*.mat', 'Selezionare un file .mat');
    
     if (isequal(file, 0))
        disp('Operazione annullata.');
        return;
     end

     data = load(fullfile(folder, file));

     if ~isfield(data, 'time') || ~isfield(data, 'var1')
        error('Il file deve contenere le variabili "time" e "var1".');
     end
     %------------------
        
     %% Inizializzazione
     %------------------
     val = data.var1;
     val = double(val);

     time = data.time;

     hours = hour(time); % Estae le ore 

     % Estrae i giorni      
     % dateshift sposta i valori all'interno di time all'inizio del giorno,
     % quindi: date 00:00:00 
     % Si hanno ora multipli valori uguali; unique estrai solamente i valori
     % unici
     days = unique(dateshift(time,'start','day'));
    
     daysNum = numel(days);  % Ritorna il numero di giorni

     % Viene inizializzata come una matrice di NaN
     avgVal = NaN(daysNum,24);
        
     dt = seconds(diff(time));
     dv = diff(val);
     ROC = dv ./ dt;
     %------------------   

     %% Lettura inputs utente
     %----------------------
     
     minVal = min(val);
     maxVal = max(val);
    
     minUserVal = GetCorrectInput(maxVal, minVal, 'Inserisci la temperatura minima: ');
     maxUserVal = GetCorrectInput(maxVal, minVal, 'Inserisci la temperatura massima: ');
     
     tol = 1e-6;

     ROCposLim = GetCorrectInput(max(tol), min(tol), 'Inserisci limite positivo ROC (es. 0.5 °C/s): ');
     ROCnegLim = GetCorrectInput(max(tol), min(tol), 'Inserisci limite negativo ROC (es. -0.5 °C/s): ');
     %ROCposLim = input('Inserisci limite positivo ROC (es. 0.5 °C/s): ');
     %ROCnegLim = input('Inserisci limite negativo ROC (es. -0.5 °C/s): ');

     freezingLim = input('Inserisci limite minimo per allarme di freezing (es. 0.01 °C/s): ');
     %----------------------

     %% Estrazione dei dati validi
     %---------------------------
     % Estrae tutti i valori dove il passo di campionamento e' uguale 60
     steadyStep    = [true; dt == 60];

     % Estrae tutti i valori dove non avviene il freezing
     notFreezing   = [true; abs(ROC) < freezingLim];
     
     % Estrae tutti i valori dove il ROC rientra nei limiti imposti
     % dall'utente
     validROC      = [true; ROC < ROCposLim & ROC > ROCnegLim];

     validVal      = ~isnan(val) & ...
                     ~isnat(time) & ...
                      val >= minUserVal & ...
                      val <= maxUserVal & ...
                      steadyStep & ...
                      validROC & ...
                      notFreezing;
     %---------------------------

     %{
     fprintf('Totale dati: %d\n', numel(temp));
     fprintf('Dati validi: %d\n', sum(valid_values));
     fprintf('Percentuale validi: %.2f%%\n', 100 * sum(valid_values)/numel(temp));
     %}
     
     %% Calcola i valori medi
     %-----------------------
     for d = 1:daysNum
        currDay = days(d);
        daysId = (dateshift(time, 'start', 'day') == currDay);
        for h = 0:23
            hoursId = (hours == h);
            % seleziona i valori che sono sia nel giorno che nell'ora
            finalId = daysId & hoursId & validVal;
            % se ci sono dati validi, calcola la media

            if any(finalId)
                avgVal(d, h+1) = round(mean(val(finalId)),2);  % h+1 perché indice MATLAB parte da 1
            end
        end
     end
     %-----------------------

     %% Stampa i valori ottenuti
     %--------------------------
     daysStr = string(days);

     results = array2table( ...
         avgVal, ...
         'RowNames', daysStr, ...
        'VariableNames', strcat("h", string(0:23)));
    
     disp(results);
     %--------------------------

        %{
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
        %}
end

function val = GetCorrectInput(maxVal, minVal, prompt)
    while true
        val = input(prompt);

        if (val <= maxVal && val >= minVal)
            break;
        end

        disp('Inserire un valore valido');
    end
end