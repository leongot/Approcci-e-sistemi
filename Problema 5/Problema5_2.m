function Problema5_2()
    % Selezione file tramite finestra
    [file, folder] = uigetfile('*.mat', 'Seleziona un file contenente time e var1');
    if isequal(file, 0)
        disp('Operazione annullata dall''utente.');
        return;
    end

    full_path = fullfile(folder, file);
    data = load(full_path);

    if ~all(ismember({'time', 'var1'}, fieldnames(data)))
        error('Il file selezionato non contiene le variabili "time" e "var1".');
    end

    time = data.time;
    var1 = data.var1;

    % Differenze temporali
    dt = diff(time);
    dt_seconds = seconds(dt);

    % Trova primo passo valido (non NaN)
    idx_ref = find(~isnan(dt_seconds), 1, 'first');
    if isempty(idx_ref)
        error('Tutti i passi sono NaN o NaT, impossibile definire passo di riferimento.');
    end
    toll = 1e-6;

    ref = scegli_passo_riferimento(dt_seconds, toll);
    diff_abs = abs(dt_seconds - ref);

    tipo_anomalia = strings(length(dt_seconds),1);
    for i=1:length(dt_seconds)
        if isnan(dt_seconds(i))
            tipo_anomalia(i) = "NaT/NaN";
        elseif diff_abs(i) > toll
            tipo_anomalia(i) = "Deviazione";
        else
            tipo_anomalia(i) = "";
        end
    end

    anomalie_idx = find(tipo_anomalia ~= "");

    if isempty(anomalie_idx)
        fprintf('[%s] Passo di campionamento costante: %.6f secondi\n\n', file, ref);
    else
        fprintf('[%s] Passo di campionamento NON costante!\n', file);

        ind_timestamp = anomalie_idx + 1;
        ind_timestamp(ind_timestamp > length(time)) = length(time);

        T = table( ...
            ind_timestamp, ...
            time(ind_timestamp), ...
            dt_seconds(anomalie_idx), ...
            diff_abs(anomalie_idx), ...
            tipo_anomalia(anomalie_idx), ...
            'VariableNames', {'Indice_time', 'Timestamp', 'Valore_s', 'Deviazione_s', 'Tipo'} ...
        );

        disp(T);
    end
end

function ref = scegli_passo_riferimento(dt_seconds, toll)
    validi = dt_seconds(~isnan(dt_seconds));
    if isempty(validi)
        error('Non ci sono valori validi per il passo.');
    end

    first_valid = validi(1);
    mediana = median(validi);
    moda_val = mode(validi);

    scarti_first = abs(validi - first_valid) > toll;
    scarti_mediana = abs(validi - mediana) > toll;
    scarti_moda = abs(validi - moda_val) > toll;

    num_div_first = sum(scarti_first);
    num_div_mediana = sum(scarti_mediana);
    num_div_moda = sum(scarti_moda);

    fprintf('Divergenze con primo valore: %d\n', num_div_first);
    fprintf('Divergenze con mediana: %d\n', num_div_mediana);
    fprintf('Divergenze con moda: %d\n', num_div_moda);

    [~, idx_min] = min([num_div_first, num_div_mediana, num_div_moda]);

    switch idx_min
        case 1
            ref = first_valid;
            scelta = 'Primo valore valido';
        case 2
            ref = mediana;
            scelta = 'Mediana';
        case 3
            ref = moda_val;
            scelta = 'Moda';
    end

    fprintf('Scelta passo di riferimento: %s = %.6f secondi\n', scelta, ref);
end
