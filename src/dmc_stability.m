clear;

K_0 = 4;
T_0 = 5;
T_1 = 1.69;
T_2 = 5.36;

G_s = tf(K_0, [T_1*T_2, T_1+T_2, 1], 'InputDelay', T_0);

G_z = c2d(G_s, 0.5, 'zoh');

kk = 10000;

wyu = zeros(1, kk);
wyy = zeros(1, kk);
yzad = 1;

s = step(G_z);
s(1) = [];

D=92;
N=20;
Nu=1;

lambda = 1;

deltaupk = zeros(1, D-1);

M = zeros(N, Nu);

for i=1:N
    for j=1:Nu
        if i>=j
            M(i, j) = s(i-j+1);
        end
    end
end

MP = zeros(N, D-1);

for i=1:N
    for j=1:D-1
        if i+j<=D
            MP(i, j) = s(i+j)-s(j);
        else
            MP(i, j) = s(D)-s(j);
        end
    end
end

I = eye(Nu);
K = (M' * M + lambda * I)\M';
Ku = K(1, :) * MP;
Ke = sum(K(1, :));

K_0 = 5.4269;
T_0 = 5;
T_1 = 1.69;
T_2 = 5.36;

step = 10;

y(1:12+step) = 0;
u(1:12+step) = 0;

G_s = tf(K_0, [T_1*T_2, T_1+T_2, 1], 'InputDelay', T_0);

Tp = 0.5;

G_z = c2d(G_s, 0.5, 'zoh');

[c, b] = tfdata(G_z, 'v');

y_fun = @(k, y, u) (-b(2)*y(k-1) - b(3)*y(k-2) + c(2)*u(k-11-step) + c(3)*u(k-12-step));

for k=13+step:kk
    y(k) = y_fun(k, y, u);

    ek = yzad - y(k);

    deltauk = Ke * ek - Ku * deltaupk';

    for n=D-1:-1:2
        deltaupk(n) = deltaupk(n-1);
    end

    deltaupk(1) = deltauk;

    u(k) = u(k-1) + deltauk;

    wyu(k) = u(k);
    wyy(k) = y(k);
end


figure;
stairs(0:kk, [0 wyu]); hold on; grid on;
xlabel('k'); title('u');

figure;
stairs(0:kk, [0 yzad*ones(1, kk)]);
hold on; grid on;
stairs(1:kk, wyy);
xlabel('k'); title('y, yzad');

% Calculated K:
% 9.1813 8.8120 8.3785 7.9338 7.4991 7.0830 6.6935 6.3341 6.0040 5.7019 5.4269

figure;
plot([1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2], [9.1813 8.8120 8.3785 7.9338 7.4991 7.0830 6.6935 6.3341 6.0040 5.7019 5.4269]/4)
grid on;
title('Obszar stabilności')
xlabel('T_0/T_0^{nom}')
ylabel('K_0/K_0^{nom}')