function Problema2()
    % Nomi delle classi
    classNames = {'Anger','Disgust','Fear','Happiness','Sadness','Surprise'};
    numClass = length(classNames);

    % Definizione di diverse matrici di confusione
    matrices = {
        % Matrice A
        % Matrice usata sulle slide
        [
         49 0  0  0  0  2;
         1  45 0  1  0  0;
         0  0  23 1  0  0;
         1  0  0  63 0  0;
         0  0  0  0  47 2;
         0  1  0  1  0  46
        ];
        
        % Matrice B
        % Matrice con piu' errori intenzionali
        [
         45 2  0  1  0  3;
         3  40 1  2  0  1;
         0  2  20 3  1  0;
         2  0  0  60 0  2;
         0  1  1 0   45 5;
         0  0  0 2   0  46
        ];
        
        % Matrice C
        % Matrice con risultati perferfetti
        diag([50 50 25 65 50 48])
    };

    % Analisi di ogni matrice
    for m = 1:length(matrices)
        confusionMatrix = matrices{m};

        fprintf('\n===== MATRICE %c =====\n', 'A' + (m - 1));
        disp( ...
            array2table( ...
            confusionMatrix, ...
            'VariableNames', classNames, ...
            'RowNames', classNames) ...
        );

        % Calcolo dei tassi di riconoscimento per classe
        accuracies = zeros(1, numClass);
        for rri = 1:numClass
            truePositive = confusionMatrix(rri,rri);
            total = sum(confusionMatrix(rri,:));
            accuracies(rri) = (truePositive / total) * 100;
        end

        % Calcolo del tasso medio
        averageAccuracy = mean(accuracies);

        % Visualizzazione risultati
        fprintf('\nTassi di riconoscimento per classe:\n');
        for ri = 1:numClass
            fprintf('%-10s: %.1f%%\n', classNames{ri}, accuracies(ri));
        end
        fprintf('Tasso medio di riconoscimento: %.1f%%\n', averageAccuracy);

        % Visualizzazione heatmap
        figure('Name', sprintf('Matrice %c', 'A' + (m - 1)));
        imagesc(confusionMatrix);
        colormap('hot');
        colorbar;
        title(sprintf('Matrice di Confusione %c', 'A' + (m - 1)));
        xticks(1:numClass); xticklabels(classNames);
        yticks(1:numClass); yticklabels(classNames);
        xlabel('Classe Predetta');
        ylabel('Classe Reale');
    end
end
