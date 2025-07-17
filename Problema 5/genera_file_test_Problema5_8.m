function genera_file_test_Problema5_7()
    % Carica il file base
    base = load('dati1.mat');
    time = base.time;
    matr1 = base.matr1;

    %% 1. Test con NaN
    matr1_nan = matr1;
    matr1_nan(10, 2) = NaN;
    matr1_nan([50 51], 3) = NaN;
    save('test_NaN.mat', 'time', 'matr1_nan');
    % Rinominare per compatibilità
    matr1 = matr1_nan;
    save('test_NaN.mat', 'time', 'matr1');

    %% 2. Test con Freezing
    matr1_freeze = matr1;
    matr1_freeze(100:120, 1) = matr1_freeze(99, 1);  % segmento costante
    matr1 = matr1_freeze;
    save('test_freezing.mat', 'time', 'matr1');

    %% 3. Test con salti (ROC violati)
    matr1_spike = matr1;
    delta = 10;  % salto improvviso
    matr1_spike(150, :) = matr1_spike(150, :) + delta;
    matr1_spike(151, :) = matr1_spike(151, :) - delta;
    matr1 = matr1_spike;
    save('test_spike.mat', 'time', 'matr1');

    %% 4. Test con mix di anomalie
    matr1_mix = matr1;
    matr1_mix(5,2) = NaN;                         % NaN singolo
    matr1_mix(60:62,1) = matr1_mix(59,1);         % freezing
    matr1_mix(200,3) = matr1_mix(199,3) + 15;     % salto
    matr1 = matr1_mix;
    save('test_mix.mat', 'time', 'matr1');

    disp('File di test generati con successo:');
    disp({'test_NaN.mat', 'test_freezing.mat', 'test_spike.mat', 'test_mix.mat'});
end
