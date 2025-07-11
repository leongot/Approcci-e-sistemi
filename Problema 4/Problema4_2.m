%calcolo guadagno, poli, zeri e costanti di tempo

% Sistemi
G = tf(3.98, conv([0.0856 1], [0.0022 1]));
Ga = tf(3.98, [0.0856 1]);

% Guadagni (valore finale della risposta allo scalino)
mu_G = dcgain(G);
mu_Ga = dcgain(Ga);

% Poli e zeri
[zG, pG, kG] = zpkdata(G, 'v');
[zGa, pGa, kGa] = zpkdata(Ga, 'v');

% Costanti di tempo = -1 / real(polo)
tau_G = -1 ./ real(pG);
tau_Ga = -1 ./ real(pGa);

% Output
disp('Sistema G(s):');
disp(['Guadagno: ', num2str(mu_G)]);
disp('Poli:'), disp(pG);
disp('Costanti di tempo:'), disp(tau_G);

disp('Sistema Ga(s):');
disp(['Guadagno: ', num2str(mu_Ga)]);
disp('Poli:'), disp(pGa);
disp('Costanti di tempo:'), disp(tau_Ga);

%risposta allo scalino e grafico + scalino
t = [0:0.001:0.5];
u = ones(size(t));  % scalino unitario

% Risposte
yG = lsim(G, u, t);
yGa = lsim(Ga, u, t);

% Grafico (replica slide 20)
figure;
plot(t, yG, 'k', 'LineWidth', 1.5); hold on;
plot(t, yGa, 'b--', 'LineWidth', 1.5);
xlabel('Tempo [s]');
ylabel('Uscita');
legend('G(s)', 'Ga(s)');
title('Risposta allo scalino unitario');

% Grafico scalino separato
figure;
plot(t, u, 'g', 'LineWidth', 1.5);
xlabel('Tempo [s]');
ylabel('Ingresso');
title('Scalino unitario');

%valori iniziali, finali e di regime
yG0 = yG(1);
yG_inf = yG(end);

yGa0 = yGa(1);
yGa_inf = yGa(end);

%Per sistemi stabili, soggetti a ingressi costanti, il valore di regime coincide con il guadagno statico
%Se il sistema è asintoticamente stabile, allora: Valore finale = Valore di regime
disp(['Valore iniziale G(s): ', num2str(yG0)]);
disp(['Valore finale G(s): ', num2str(yG_inf)]);

disp(['Valore iniziale Ga(s): ', num2str(yGa0)]);
disp(['Valore finale Ga(s): ', num2str(yGa_inf)]);

%indicare valore iniziale su grafico
figure;
plot(t, yG, 'k', 'LineWidth', 1.5); hold on;
plot(t, yGa, 'b--', 'LineWidth', 1.5);
plot(0, yG0, 'ro', 'MarkerSize', 8, 'DisplayName', 'y(0) G(s)');
xlabel('Tempo [s]');
ylabel('Uscita');
legend('G(s)', 'Ga(s)', 'y(0) G(s)');
title('Risposta con valore iniziale evidenziato');


% Tempo normalizzato e uscita normalizzata (replica linea azzurra slide 16)
% - risposta normalizzata
t_norm = t / tau_Ga;
y_norm = yGa / mu_Ga;

figure;
plot(t_norm, y_norm, 'b', 'LineWidth', 1.5);
xlabel('t / T');
ylabel('y / \mu');
title('Risposta normalizzata Ga(s)');
grid on;

% tempo salita Ts per Ga(s)
Ts_Ga = 2.2 * tau_Ga;
disp(['Tempo di salita Ts per Ga(s): ', num2str(Ts_Ga), ' s']);


