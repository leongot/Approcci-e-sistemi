clear; clc;

choice = questdlg('Vuoi inserire i parametri numerici o calcolare simbolicamente?', ...
    'Scelta input', ...
    'Parametri numerici','Calcolo simbolico','Parametri numerici');

if strcmp(choice, 'Parametri numerici')
    prompt = {'R (Ohm):', 'L (H):', 'k (Nm/A):', 'h (Nms):', 'J (kgm^2):'};
    titleDlg = 'Inserisci i parametri del sistema';
    dims = [1 35];
    definput = {'1', '0.5', '0.1', '0.02', '0.05'};
    answer = inputdlg(prompt, titleDlg, dims, definput);

    if isempty(answer)
        error('Input annullato dall’utente.');
    end

    R = str2double(answer{1});
    L = str2double(answer{2});
    k = str2double(answer{3});
    h = str2double(answer{4});
    J = str2double(answer{5});

    if any(isnan([R L k h J])) || L == 0 || J == 0
        error('Parametri non validi o nulli. Verifica i valori inseriti.');
    end
else
    % Simbolici
    syms R L k h J real
end

syms s real

% === Matrici del sistema ===
A = [-R/L, -k/L;
      k/J, -h/J];

B = [1/L,    0;
     0,   -1/J];

C = eye(2);
D = zeros(2);
I = eye(2);

% === Polinomio caratteristico φ(s) ===
phi = simplify(det(s*I - A));

% === Funzione di trasferimento matriciale ===
G = simplify(C * inv(s*I - A) * B + D);

% === Numeratore simbolico N(s) = φ(s) * G(s) ===
N = simplify(phi * G);

% --- Visualizzazione migliorata ---

fprintf('\n==============================\n');
fprintf(' POLINOMIO CARATTERISTICO φ(s)\n');
fprintf('==============================\n\n');
disp(char(phi));

fprintf('\n==============================\n');
fprintf(' MATRICE FUNZIONE DI TRASFERIMENTO G(s)\n');
fprintf('==============================\n\n');

[nr, nc] = size(G);
for i=1:nr
    rowStr = '';
    for j=1:nc
        rowStr = [rowStr, char(G(i,j))];
        if j ~= nc
            rowStr = [rowStr, '   |   '];
        end
    end
    disp(rowStr);
end

fprintf('\n==============================\n');
fprintf(' MATRICE NUMERATORE N(s)\n');
fprintf('==============================\n\n');

[nrN, ncN] = size(N);
for i=1:nrN
    rowStr = '';
    for j=1:ncN
        rowStr = [rowStr, char(N(i,j))];
        if j ~= ncN
            rowStr = [rowStr, '   |   '];
        end
    end
    disp(rowStr);
end

fprintf('\n');

% --- Stampa parametri numerici se presenti ---

if exist('R','var') && ~isa(R,'sym')
    fprintf('Parametri inseriti:\n');
    fprintf('R = %.4f Ohm\n', R);
    fprintf('L = %.4f H\n', L);
    fprintf('k = %.4f Nm/A\n', k);
    fprintf('h = %.4f Nms\n', h);
    fprintf('J = %.4f kgm^2\n', J);
    fprintf('\n');
end
