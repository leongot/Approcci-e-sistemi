syms s R L J h k

% Polinomio caratteristico φ(s)
phi = s^2 + (R/L + h/J)*s + (k^2 + R*h)/(L*J);

% Matrice numeratore
N = [ (s + h/J)/L,    k/(L*J);
       k/(L*J),     -(s + R/L)/J ];

% Matrice funzione di trasferimento
G = simplify( (1/phi) * N );
