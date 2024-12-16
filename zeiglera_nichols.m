clear

K_o = 4;
T_o = 5;
T_1 = 1.69;
T_2 = 5.36;

G_s = tf(K_o, [T_1*T_2, T_1 + T_2, 1], 'InputDelay', T_o);

K_k = 0.56509;
T_k = 20;

P = pidstd(K_k, inf, 0);
response = feedback(P*G_s, 1);

figure;
step(response);
grid on;
ylabel('Amplituda');
xlabel('Czas')
title('Odpowiedź skokowa 1');

K_p = 0.6 * K_k;
T_i = 0.5 * T_k;
T_d = 0.12 * T_k;

P = pidstd(K_p, T_i, T_d);
response = feedback(P*G_s, 1);

figure;
step(response, 100);
grid on;
ylabel('Amplituda');
xlabel('Czas')
title('Odpowiedź skokowa 2');

Tp = 0.5;

r_0 = K_p * (1 + Tp/(2*T_i) + T_d/Tp);
r_1 = K_p * (-1 + Tp/(2*T_i) - 2*T_d/Tp);
r_2 = K_p * (T_d/Tp);

disp('Discrete PID parameters:');
disp(['r_0: ', num2str(r_0)]);
disp(['r_1: ', num2str(r_1)]);
disp(['r_2: ', num2str(r_2)]);
