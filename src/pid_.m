clear

K_0 = 4;
T_0 = 5;
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

kk=200;

y_zad(1:9)=0; y_zad(10:kk)=1;
y(1:13)=0;
u(1:13)=0;
e(1:13)=0;

for k=13:kk
    y(k) = y_fun(k, y, u);
    e(k) = y_zad(k)-y(k);
    u(k) = r_2*e(k-2)+r_1*e(k-1)+r_0*e(k)+u(k-1);
end

figure;
stairs(u);
title('u');
xlabel('k');

figure;
stairs(y);
hold on;
stairs(y_zad,':');
title('y_{zad}, y');
xlabel('k');