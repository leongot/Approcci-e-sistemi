function Problema3()
    % Esempio di immagine 10x10 binaria (0 = nero, 1 = bianco)
    img1 = randi([0 1], 10, 10);  % immagine casuale
    img2 = zeros(10,10); img2(3:7,3:7) = 1;  % pattern centrale bianco

    immagini = {img1, img2};

    for idx = 1:length(immagini)
        fprintf('\n--- Immagine %d ---\n', idx);
        curimg = immagini{idx};
        disp(curimg);

        % Visualizza l'immagine
        figure; imshow(curimg, 'InitialMagnification', 'fit');
        title(sprintf('Immagine %d', idx));

        csd = [0, 0];  % [bianco, nero]

        % Scorri l'immagine con finestra 3x3
        for r = 1:(size(curimg,1)-2)
            for c = 1:(size(curimg,2)-2)
                window = curimg(r:r+2, c:c+2);
                csd(1) = csd(1) + any(window(:) == 1);
                csd(2) = csd(2) + any(window(:) == 0);
            end
        end

        fprintf('Color Structure Descriptor [bianco nero]: [%d %d]\n', csd);
    end
end
