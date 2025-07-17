function Problema5_5()
    [file, folder] = uigetfile('*.mat', 'Seleziona un file .mat con time e var1');
    if isequal(file, 0)
        disp('Operazione annullata.');
        return;
    end

    data = load(fullfile(folder, file));
    if ~isfield(data, 'time') || ~isfield(data, 'var1')
        error('Il file deve contenere le variabili "time" e "var1".');
    end

    time = data.time;
    var1 = data.var1;

    dt = seconds(diff(time));
    dv = diff(var1);
    ROC = dv ./ dt;

    % Limiti inseriti dall’utente
    ROCPositiveLim = input('Inserisci limite positivo ROC (es. 0.5 °C/s): ');
    ROCNegativeLim = input('Inserisci limite negativo ROC (es. -0.5 °C/s): ');

    % Rilevamento allarmi con limiti utente
    user_warnings = strings(length(ROC), 1);
    for i = 1:length(ROC)
        if ROC(i) > ROCPositiveLim
            user_warnings(i) = "ROC positivo";
        elseif ROC(i) < ROCNegativeLim
            user_warnings(i) = "ROC negativo";
        end
    end

    user_ids = find(user_warnings ~= "");
    if isempty(user_ids)
        disp('Nessun allarme rilevato con i limiti inseriti dall’utente.');
    else
        T_user = table( ...
            user_ids + 1, time(user_ids + 1), ROC(user_ids), user_warnings(user_ids), ...
            'VariableNames', {'Indice', 'Timestamp', 'ROC', 'Tipo_Allarme'} ...
        );
        disp('Eventi di allarme rilevati (limiti utente):');
        disp(T_user);
    end

    % Se il file non è dati3.mat, uso i suoi limiti
    if ~strcmp(file, 'dati3.mat')
        dati3 = load(fullfile(folder, 'dati3.mat'));
        d3_dv = diff(dati3.var1);
        d3_dmax = max(d3_dv);
        d3_dmin = min(d3_dv);

        auto_warnings = strings(length(ROC), 1);
        for i = 1:length(ROC)
            if ROC(i) > d3_dmax
                auto_warnings(i) = "ROC positivo";
            elseif ROC(i) < d3_dmin
                auto_warnings(i) = "ROC negativo";
            end
        end

        auto_ids = find(auto_warnings ~= "");
        if isempty(auto_ids)
            disp('Nessun allarme rilevato con i limiti da dati3.mat.');
        else
            T_auto = table( ...
                auto_ids + 1, time(auto_ids + 1), ROC(auto_ids), auto_warnings(auto_ids), ...
                'VariableNames', {'Indice', 'Timestamp', 'ROC', 'Tipo_Allarme'} ...
            );
            disp('Eventi di allarme rilevati (limiti da dati3.mat):');
            disp(T_auto);
        end
    end

    % Plot ROC + soglie + allarmi
    figure;
    plot(time(2:end), ROC, 'k', 'DisplayName', 'ROC'); hold on;
    yline(ROCPositiveLim, '--r', 'Limite + utente', 'DisplayName', 'Limite + utente');
    yline(ROCNegativeLim, '--b', 'Limite - utente', 'DisplayName', 'Limite - utente');

    if exist('d3_dmax', 'var')
        yline(d3_dmax, ':r', 'Limite + dati3', 'DisplayName', 'Limite + dati3');
        yline(d3_dmin, ':b', 'Limite - dati3', 'DisplayName', 'Limite - dati3');
    end

    % Evidenzia punti di allarme (utente)
    if ~isempty(user_ids)
        plot(time(user_ids + 1), ROC(user_ids), 'ro', 'DisplayName', 'Allarmi utente');
    end

    % Evidenzia punti di allarme (dati3)
    if exist('auto_ids', 'var') && ~isempty(auto_ids)
        plot(time(auto_ids + 1), ROC(auto_ids), 'bx', 'DisplayName', 'Allarmi dati3');
    end

    xlabel('Tempo');
    ylabel('ROC [°C/s]');
    title('Velocità di variazione var1 (ROC) e superamenti soglie');
    legend('Location', 'best');
    grid on;
end
