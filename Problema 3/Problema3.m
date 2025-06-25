function calcolaCSD()
    % Esempio di immagine 10x10 binaria (0 = nero, 1 = bianco)
    img1 = randi([0 1], 10, 10);  % immagine casuale
    img2 = zeros(10,10); img2(3:7,3:7) = 1;  % pattern centrale bianco

    immagini = {img1, img2};

    for idx = 1:length(immagini)
        fprintf('\n--- Immagine %d ---\n', idx);
        curimg = immagini{idx};
        disp(curimg);

        csd = [0, 0];  % [bianco, nero]

        % Scorri l'immagine con finestra 3x3
        for r = 1:(size(curimg,1)-2)
            for c = 1:(size(curimg,2)-2)
                window = curimg(r:r+2, c:c+2);
                if any(window(:) == 1)
                    csd(1) = csd(1) + 1; % bianco presente
                end
                if any(window(:) == 0)
                    csd(2) = csd(2) + 1; % nero presente
                end
            end
        end

        fprintf('Color Structure Descriptor [bianco nero]: [%d %d]\n', csd);
    end
end
