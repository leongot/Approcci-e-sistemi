% Avvia simulazione
try
    simOut = sim("Simulink_4_3.slx");
catch ME
    error('Impossibile eseguire la simulazione: %s', ME.message);
end
% === Verifica che i segnali esistano in simOut ===
if ~isfield(simOut, 'y_Ga') || ~isfield(simOut, 'u_step')
    error(['Il file Simulink non contiene i segnali ' ...
           'y_Ga e/o u_step. Verifica il modello Simulink.']);
end

% Estrai i dati da 'simOut'
y = simOut.y_Ga;        % risposta del sistema (uscita)
u = simOut.u_step;      % segnale di ingresso (scalino)

% === Controllo dimensionale delle variabili ===
if ~isvector(y) || ~isvector(u)
    error('y e u devono essere vettori. Attualmente: y isvector = %d, u isvector = %d', ...
          isvector(y), isvector(u));
end
if length(y) ~= length(u)
    error('Dimensione incompatibile: length(y) = %d, length(u) = %d', length(y), length(u));
end

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
