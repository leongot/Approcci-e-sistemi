function Problema5_4()

    fprintf('\nDEMO realizzata da: Leonardo Gottani, Nicola Olivieri, Emanuele Bruno\n');

    %% Lettura e caricamento dei dati
    % Selezione file da analizzare
    [file, folder] = uigetfile('*.mat', 'Seleziona un file contenente var1 e time');

    if isequal(file, 0)
        disp('Operazione annullata.');
        return;
    end

    nome_file = fullfile(folder, file);
    nome_file_dati3 = fullfile(folder, 'dati3.mat');  % cerca dati3.mat nella stessa cartella

    % Caricamento dati3.mat e calcolo min/max 
    
    try
        [var1_dati3, ~] = carica_dati(nome_file_dati3);
    catch e
        fprintf('Errore nel caricamento di dati3.mat: %s\n', e.message);
        return;
    end

    % Calcolo limiti
    limite_min = min(var1_dati3);
    limite_max = max(var1_dati3);

    % Stampa risultati dati3
    fprintf('\n=== Analisi dati3.mat ===\n');
    fprintf('Valore minimo di var1: %.3f\n', limite_min);
    fprintf('Valore massimo di var1: %.3f\n', limite_max);

    % Caricamento file selezionato
    try
        [var1, time] = carica_dati(nome_file);
    catch ME
        fprintf('Errore nel caricamento di %s: %s\n', nome_file, ME.message);
        return;
    end

    if length(var1) ~= length(time)
        error('Le variabili "var1" e "time" devono avere la stessa lunghezza.');
    end

    if isempty(var1)
        error('Il vettore var1 è vuoto.');
    end

    %% Input utente
    scelta = input_testo_valido(['Vuoi usare i limiti calcolati da dati3.mat ' ...
    '(min: ' num2str(limite_min) ', max: ' num2str(limite_max) ')? (s/n): ']);

    if strcmpi(scelta, 's')
        soglia_inferiore = limite_min;
        soglia_superiore = limite_max;

        while true
            isteresi_inferiore = input_valido('Inserisci il limite di attenzione basso: ');
            isteresi_superiore = input_valido('Inserisci il limite di attenzione alto: ');

            if soglia_inferiore < isteresi_inferiore && ...
               isteresi_inferiore < isteresi_superiore && ...
               isteresi_superiore < soglia_superiore
                fprintf('Soglie coerenti. Sono stati usati i limiti min/max ricavati da dati3.mat\n');
                break;
            else
                fprintf('Soglie incoerenti: assicurati che\n');
                fprintf('- Limite sicurezza basso < Limite attenzione basso < Limite attenzione alto < Limite sicurezza alto\n');
                fprintf('Riprova.\n\n');
            end
        end
    else
        while true
            soglia_inferiore = input_valido('Inserisci il livello di sicurezza basso: ');
            isteresi_inferiore = input_valido('Inserisci il livello di attenzione basso: ');
            soglia_superiore = input_valido('Inserisci il livello di sicurezza alto: ');
            isteresi_superiore = input_valido('Inserisci il livello di attenzione alto: ');

            if soglia_inferiore < isteresi_inferiore && ...
               isteresi_inferiore < isteresi_superiore && ...
               isteresi_superiore < soglia_superiore

                fprintf('Soglie coerenti.\n');
                break;
            else
                fprintf('Soglie incoerenti: assicurati che\n');
                fprintf('- Limite sicurezza basso < Limite attenzione basso < Limite attenzione alto < Limite sicurezza alto\n');
                fprintf('Riprova.\n\n');
            end
        end
    end

    %% Analisi valori
    fprintf('\n Rilevamento valori fuori soglia in %s \n', nome_file);
    rileva_superamento_limiti(var1, time, soglia_inferiore, soglia_superiore, isteresi_inferiore, isteresi_superiore);
end

% Funzione per caricare var1 e time 
function [var1, time] = carica_dati(nome_file)
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

% Funzione per rilevare superamenti di soglia con isteresi
function rileva_superamento_limiti(var1, time, soglia_inf, soglia_sup, isteresi_inf, isteresi_sup)

    if isempty(var1)
        disp('Il vettore var1 è vuoto. Nessuna analisi effettuata.');
        return;
    end

    % Conversione robusta del tempo in datetime
    if ~isdatetime(time)
        time = datetime(time, 'ConvertFrom', 'datenum');
    end

    % Preallocazione di vari array 
    attivazioni_sup     = [];
    disattivazioni_sup  = [];
    attivazioni_inf     = [];
    disattivazioni_inf  = [];

    count = 0;

    allarme_sup = false;
    allarme_inf = false;

    for i = 1:length(var1)
        giorno = time(i);
        valore = var1(i);

        % Allarme superiore
        if ~allarme_sup && valore > soglia_sup
            allarme_sup = true;
            attivazioni_sup(end+1) = i;
            fprintf('\n+++ ALLARME SUPERIORE ATTIVATO! +++\nGiorno: %s \nValore: %.3f \n', giorno, valore);
            count = count + 1;
        elseif allarme_sup && valore < isteresi_sup
            allarme_sup = false;
            disattivazioni_sup(end+1) = i;
            fprintf('\n--- ALLARME SUPERIORE DISATTIVATO! ---\nGiorno: %s \nValore: %.3f \n', giorno, valore);
        end

        % Allarme inferiore
        if ~allarme_inf && valore < soglia_inf
            allarme_inf = true;
            attivazioni_inf(end+1) = i;
            fprintf('\n+++ ALLARME INFERIORE ATTIVATO! +++\nGiorno: %s \nValore: %.3f \n', giorno, valore);
            count = count + 1;
        elseif allarme_inf && valore > isteresi_inf
            allarme_inf = false;
            disattivazioni_inf(end+1) = i;
            fprintf('\n--- ALLARME INFERIORE DISATTIVATO! ---\nGiorno: %s \nValore: %.3f \n', giorno, valore);
        end
    end

    if count == 0
        fprintf('\nNessun valore fuori soglia rilevato.\n');
    else
        fprintf('\nTotale allarmi rilevati: %d\n', count);
    end

    % Visualizzazione del grafico opzionale
    while true
        choice = input("Si desidera visualizzare il grafico? S/N: ", "s");

        if isequal(upper(choice), 'N')
            disp('Chiusura programma...');
            return
        elseif isequal(upper(choice), 'S')
            figure;
            plot(time, var1, '-k'); hold on;
            title('Andamento var1 e Allarmi');
            xlabel('Tempo'); ylabel('Valore var1');
            grid on;

            yline(soglia_sup, '--r', 'Limite sicurezza alto');
            yline(isteresi_sup, ':r', 'Limite attenzione alto');
            yline(soglia_inf, '--b', 'Limite sicurezza basso');
            yline(isteresi_inf, ':b', 'Limite attenzione basso');

            plot(time(attivazioni_sup), var1(attivazioni_sup), 'ro', 'MarkerFaceColor', 'r');
            plot(time(disattivazioni_sup), var1(disattivazioni_sup), 'go', 'MarkerFaceColor', 'g');
            plot(time(attivazioni_inf), var1(attivazioni_inf), 'bo', 'MarkerFaceColor', 'b');
            plot(time(disattivazioni_inf), var1(disattivazioni_inf), 'yo', 'MarkerFaceColor', 'y');

            legend('var1', ...
                'Limite sicurezza alto', 'Limite attenzione alto', ...
                'Limite sicurezza basso', 'Limite attenzione basso', ...
                'Attivazione Sup', 'Disattivazione Sup', ...
                'Attivazione Inf', 'Disattivazione Inf', ...
                'Location', 'best');

            return
        else
            disp("Input non valido. Inserire 'S' per sì o 'N' per no.")
        end
    end
end

% Funzione di input sicuro
function val = input_valido(prompt)
    while true
        val = input(prompt);
        if ~isempty(val) && isnumeric(val)
            break;
        else
            disp('Valore non valido. Inserisci un numero.');
        end
    end
end

function val = input_testo_valido(prompt)
    while true
        val = input(prompt, 's');
        if any(strcmpi(val, {'s','n'}))
            break;
        else
            disp("Input non valido. Inserire 's' per sì o 'n' per no.");
        end
    end
end