% Avvia simulazione
simOut = sim("Simulink_4_3.slx");

% Estrai i dati da 'simOut'
y = simOut.y_Ga;        % risposta del sistema (uscita)
u = simOut.u_step;      % segnale di ingresso (scalino)

% Ricostruisci vettore temporale
t = linspace(0, 0.5, length(y));

% Grafico della risposta allo scalino
figure;
plot(t, y, 'b', 'LineWidth', 1.5);
xlabel('Tempo (s)');
ylabel('y_{Ga}(t)');
title('Risposta allo scalino – G_a(s)');
grid on;

% Grafico del segnale di ingresso 
figure;
plot(t, u, 'k--', 'LineWidth', 1.5);
xlabel('Tempo (s)');
ylabel('u(t)');
title('Segnale di ingresso (scalino)');
grid on;
