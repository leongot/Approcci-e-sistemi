function Problema5_2()
    % Richiesta nome file
    nome_file = input('Inserisci il nome del dataset (dati2 o dati3): ', 's');
    
    % Verifica e caricamento
    if strcmp(nome_file, 'dati2')
        data = load('dati2.mat');
    elseif strcmp(nome_file, 'dati3')
        data = load('dati3.mat');
    else
        error('Il file specificato non esiste o il nome è errato.');
    end

    % Estrazione variabili
    time = data.time;
    var1 = data.var1;

    % Calcolo differenze temporali
    dt = diff(time);  % differenze datetime, possono contenere NaT

    % Converti differenze in secondi, NaT diventa NaN
    dt_seconds = seconds(dt);

    ref = dt_seconds(1);       % passo di riferimento (potrebbe essere NaN!)
    toll = 1e-6;               % tolleranza

    % Calcolo deviazioni assolute; gestiamo NaN: mettiamo deviazione alta (inf)
    diff_abs = abs(dt_seconds - ref);
    diff_abs(isnan(diff_abs)) = Inf;  % NaN viene considerato deviazione massima

    % Controllo costanza
    if all(diff_abs < toll)
        fprintf('[%s.mat] Passo di campionamento costante: %.6f secondi\n\n', nome_file, ref);
    else
        fprintf('[%s.mat] Passo di campionamento NON costante!\n');
        fprintf('Passo di riferimento: %.6f secondi\n\n', ref);
    end

    % Stampa tutte le differenze con segnalazione NaT/NaN
    fprintf('Indice\tValore (s)\tDeviazione (s)\n');
    fprintf('------------------------------------------\n');
    for i = 1:length(dt_seconds)
        val_str = num2str(dt_seconds(i), '%.6f');
        dev_str = num2str(diff_abs(i), '%.6f');

        % Se valore o deviazione è Inf, sostituisci con stringa 'NaT/NaN'
        if isinf(diff_abs(i)) || isnan(dt_seconds(i))
            val_str = 'NaT/NaN';
            dev_str = 'NaT/NaN';
        end

        fprintf('%d\t%s\t\t%s\n', i, val_str, dev_str);
    end
end
