clear

K_o = 4;
T_o = 5;
T_1 = 1.69;
T_2 = 5.36;
Tp = 0.5;

G_s = tf(K_o, [T_1*T_2, T_1 + T_2, 1], 'InputDelay', T_o);

G_z = c2d(G_s, Tp, 'zoh');

[c, b] = tfdata(G_z, 'v');

y_fun = @(k, y, u) (-b(2)*y(k-1) - b(3)*y(k-2) + c(2)*u(k-11) + c(3)*u(k-12));

kk = 100;
u = ones(kk, 1);
t = (0:kk-1) * Tp;
y = zeros(1, kk);

for k = 13:kk
    y(k) = y_fun(k, y, u);
end

figure;
stairs(t, y);
grid on;
title("Step response");
xlabel('k')
ylabel('y')