% === Dichiarazione simbolica ===
syms s R L k h J real

% === Matrici del sistema ===
A = [-R/L, -k/L;
      k/J, -h/J];

B = [1/L,    0;
     0,   -1/J];

C = eye(2);          % C = I (uscite = stati)
D = zeros(2);        % D = 0

I = eye(2);          % Matrice identità

% === Polinomio caratteristico φ(s) ===
phi = simplify(det(s*I - A));
disp('Polinomio caratteristico φ(s) = det(sI - A):');
pretty(phi)

% === Funzione di trasferimento matriciale ===
G = simplify(C * inv(s*I - A) * B + D);

disp('Matrice delle funzioni di trasferimento G(s):');
pretty(G)

% === Forma simbolica evidenziando il denominatore φ(s) ===
% Calcolo il numeratore simbolico N(s) = φ(s) * G(s)
N = simplify(phi * G);

disp('Matrice numeratore N(s), tale che G(s) = N(s)/φ(s):');
pretty(N)