clear

K_o = 4;
T_o = 5;
T_1 = 1.69;
T_2 = 5.36;
Tp = 0.5;

G_s = tf(K_o, [T_1*T_2, T_1 + T_2, 1], 'InputDelay', T_o);

G_z = c2d(G_s, Tp, 'zoh');

disp('Discrete Transfer Function G(z):');
G_z

% Step response of the continuous system
figure;
step(G_s);
title('Odpowiedź skokowa transmitancji ciągłej G(s)');
grid on;

% Step response of the discrete system
figure;
step(G_z);
title('Odpowiedź skokowa transmitancji dyskretnej G(z)');
grid on;

% Compare the two step responses
figure;
step(G_s, 'b', G_z, 'r--');
title('Porównanie odpowiedzi skokowych');
legend('Ciągła G(s)', 'Dyskretna G(z)');
grid on;

K_ss_continuous = dcgain(G_s);

K_ss_discrete = dcgain(G_z);

% Display the gains
disp(['Steady-State Gain of Continuous System: ', num2str(K_ss_continuous)]);
disp(['Steady-State Gain of Discrete System: ', num2str(K_ss_discrete)]);
