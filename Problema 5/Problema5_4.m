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
        isteresi_inferiore= input('Inserisci la soglia di isteresi inferiore: ');
        isteresi_superiore = input('Inserisci la soglia di isteresi superiore: ');
        fprintf('Usati limiti da dati3.mat\n');
    else
        soglia_inferiore = input('Inserisci la soglia inferiore per livello attezione basso: ');
        isteresi_inferiore= input('Inserisci la soglia di isteresi inferiore: ');
        soglia_superiore = input('Inserisci la soglia superiore per livello attenzione alto: ');
        isteresi_superiore = input('Inserisci la soglia di isteresi superiore: ');
    end

    % Analisi valori fuori soglia
    fprintf('\n=== Rilevamento valori fuori soglia in %s ===\n', nome_file);
    rileva_superamento_limiti(var1, time, soglia_inferiore, soglia_superiore, isteresi_inferiore, isteresi_superiore);
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
function rileva_superamento_limiti(var1, time, soglia_inferiore, soglia_superiore, isteresi_inferiore, isteresi_superiore)
    count = 0;
     allarme_superiore_ON = false;
     allarme_inferiore_ON = false;
    for i = 1:length(var1)
        giorno = datetime(time(i));
        valore = var1(i);

        % Gestione allarme superiore con isteresi
        if ~allarme_superiore_ON && valore > soglia_superiore
            allarme_superiore_ON = true;
            fprintf('\n+++ ALLARME SUPERIORE ATTIVATO! +++\nGiorno: %s \nValore: %.3f \nLimite sicurezza alto:%.3f \nIndex: %d\n',giorno, valore, soglia_superiore,i);
            count = count + 1;
        elseif allarme_superiore_ON && valore < isteresi_superiore
            allarme_superiore_ON = false;
            fprintf('\n--- ALLARME SUPERIORE DISATTIVATO! ----\nGiorno: %s \nValore: %.3f \nLimite attenzione alto: %.3f \nIndex: %d\n', giorno, valore, isteresi_superiore, i);
        end

        % Gestione allarme inferiore con isteresi
        if ~allarme_inferiore_ON && valore < soglia_inferiore
            allarme_inferiore_ON = true;
            fprintf('\n+++ ALLARME INFERIORE ATTIVATO! +++ \nGiorno: %s \nValore: %.3f \nLimite sicurezza basso: %.3f \nIndex: %d \n', giorno, valore, soglia_inferiore,i);
            count = count + 1;
        elseif allarme_inferiore_ON && valore > isteresi_inferiore
            allarme_inferiore_ON = false;
            fprintf('\n--- ALLARME SUPERIORE DISATTIVATO! --- \nGiorno: %s \nValore: %.3f \nLimite attenzione basso: %.3f \nIndex: %d \n', giorno, valore, isteresi_inferiore,i);
        end

        if allarme_superiore_ON
            fprintf('\nALLARME SUPERIORE ATTIVO: \nValore: %.3f \nGiorno: %s \nLimite sicurezza alto: %.3f \nLimite attenzione alto: %.3f \nIndex: %d\n', valore, giorno, soglia_superiore, isteresi_superiore, i);
        end

        if allarme_inferiore_ON
            fprintf('\nALLARME INFERIORE ATTIVO: \nValore: %.3f \nGiorno: %s \nLimite sicurezza basso: %.3f \nLimite attenzione basso: %.3f \nIndex: %d\n', valore, giorno, soglia_inferiore, isteresi_inferiore, i);
        end
    end

    if count == 0
        fprintf('Nessun valore fuori soglia.\n');
    else
        fprintf('\nTotale valori fuori soglia: %d\n', count);
    end
end