clear

K_0 = 4;
T_0 = 10;
T_1 = 1.69;
T_2 = 5.36;
Tp = 0.5;

G_s = tf(K_0, [T_1*T_2, T_1 + T_2, 1], 'InputDelay', T_0);

G_z = c2d(G_s, Tp, 'zoh');

[c, b] = tfdata(G_z, 'v');

y_fun = @(k, y, u) (-b(2)*y(k-1) - b(3)*y(k-2) + c(2)*u(k-11) + c(3)*u(k-12));

K_k = 0.56509;
T_k = 20;

K_p = 0.6 * K_k;
T_i = 0.5 * T_k;
T_d = 0.12 * T_k;

r_0 = K_p * (1 + Tp/(2*T_i) + T_d/Tp);
r_1 = K_p * (-1 + Tp/(2*T_i) - 2*T_d/Tp);
r_2 = K_p * (T_d/Tp);

kk=10000;

yzad(1:9)=0; yzad(10:kk)=1;

step = 10;

y(1:12+step) = 0;
u(1:12+step) = 0;
e(1:12+step) = 0;

for k=13+step:kk
    y(k) = y_fun(k, y, u);
    e(k) = yzad(k)-y(k);
    u(k) = r_2*e(k-2)+r_1*e(k-1)+r_0*e(k)+u(k-1);
end

figure; stairs(u);
title('u'); xlabel('k');
grid on;
figure; stairs(y); hold on; stairs(yzad,':');
grid on;
title('yzad, y'); xlabel('k');

% Calculated K:
% 1.5775 1.5088 1.4450 1.3925 1.3450 1.2950 1.2500 1.2050 1.1625 1.1200 1.0850
figure;
plot(1:0.1:2, [1.5775 1.5088 1.4450 1.3925 1.3450 1.2950 1.2500 1.2050 1.1625 1.1200 1.0850])
grid on;
title('Obszar stabilności')
xlabel('T_0/T_0^{nom}')
ylabel('K_0/K_0^{nom}')