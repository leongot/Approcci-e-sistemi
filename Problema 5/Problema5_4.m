function Problema5_4()
    %% --- PARTE 1: Caricamento dati3.mat e calcolo min/max ---
    nome_file_dati3 = 'dati3.mat';

    try
         [var1_dati3, ~] = carica_var1(nome_file_dati3);
    catch ME
        fprintf('Errore nel caricamento di dati3.mat: %s\n', ME.message);
        return;
    end

    % Calcolo limiti
    limite_min = min(var1_dati3);
    limite_max = max(var1_dati3);

    % Stampa risultati dati3
    fprintf('\n=== Analisi dati3.mat ===\n');
    fprintf('Valore minimo di var1: %.3f\n', limite_min);
    fprintf('Valore massimo di var1: %.3f\n', limite_max);

    %% --- PARTE 2: Analisi altro file ---
    nome_file = input('\nInserisci il nome del file da analizzare (es. dati5 o dati3): ', 's');

    % Aggiungi estensione .mat se mancante
    if ~endsWith(nome_file, '.mat')
        nome_file = [nome_file '.mat'];
    end

    % Caricamento secondo file
    try
          [var1, time] = carica_var1(nome_file);
    catch ME
        fprintf('Errore nel caricamento di %s: %s\n', nome_file, ME.message);
        return;
    end

    % Chiedi se usare i limiti da dati3.mat o inserire manualmente
    scelta = input(['Vuoi usare i limiti calcolati da dati3.mat ' ...
                    '(min: '  num2str(limite_min) ', max: '  num2str(limite_max) ')? (s/n): '], 's');

    if strcmpi(scelta, 's')
        soglia_inferiore = limite_min;
        soglia_superiore = limite_max;
        fprintf('Usati limiti da dati3.mat\n');
    else
        soglia_inferiore = input('Inserisci la soglia inferiore per livello attezione basso: ');
        soglia_superiore = input('Inserisci la soglia superiore per livello attenzione alto: ');
    end

    % Analisi valori fuori soglia
    fprintf('\n=== Rilevamento valori fuori soglia in %s ===\n', nome_file);
    rileva_superamento_limiti(var1, time, soglia_inferiore, soglia_superiore);
end

%% --- Funzione per caricare var1 con controlli ---
function [var1, time] = carica_var1(nome_file)
    if ~isfile(nome_file)
        error('Il file %s non esiste.', nome_file);
    end

    data = load(nome_file);

    if ~isfield(data, 'var1') || ~isfield(data, 'time')
        error('Il file %s deve contenere sia "var1" che "time".', nome_file);
    end

    var1 = data.var1;
    time = data.time;
end

%% --- Funzione per rilevare superamenti di soglia ---
function rileva_superamento_limiti(var1, time, soglia_inferiore, soglia_superiore)
    count = 0;
    for i = 1:length(var1)
        giorno = datetime(time(i));
        valore = var1(i);
        if valore < soglia_inferiore
            fprintf('Valore %.3f  indice %d nel giorno: %s è SOTTO la soglia minima (%.3f)\n', valore, i, giorno ,soglia_inferiore);
            count = count + 1;
        elseif valore > soglia_superiore
            fprintf('Valore %.3f indice %d nel giorno: %s è SOPRA la soglia massima (%.3f)\n', valore, i, giorno, soglia_superiore);
            count = count + 1;
        end
    end

    if count == 0
        fprintf('Nessun valore fuori soglia.\n');
    else
        fprintf('\nTotale valori fuori soglia: %d\n', count);
    end
end