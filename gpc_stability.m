clear;

K_0 = 4;
T_0 = 5;
T_1 = 1.69;
T_2 = 5.36;

G_s = tf(K_0, [T_1*T_2, T_1+T_2, 1], 'InputDelay', T_0);

G_z = c2d(G_s, 0.5, 'zoh');

[c, b] = tfdata(G_z, 'v');

y_fun = @(k, y, u) (-b(2)*y(k-1) - b(3)*y(k-2) + c(2)*u(k-11) + c(3)*u(k-12));

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

y(1:12) = 0;
u(1:12) = 0;

deltaupk = zeros(1, D-1);

M = zeros(N, Nu);

for i = 1:N
    for j = 1:Nu
        if i >= j
            M(i, j) = s(i-j+1);
        end
    end
end

I = eye(Nu);
K = (M' * M + lambda * I) \ M';

disturbance(1:40) = 0;
disturbance(41: kk) = 0;
d = zeros(1, kk);

K_0 = 5.6985;
T_0 = 5;
T_1 = 1.69;
T_2 = 5.36;

step = 0;

y(1:12+step) = 0;
u(1:12+step) = 0;

G_s = tf(K_0, [T_1*T_2, T_1+T_2, 1], 'InputDelay', T_0);

Tp = 0.5;

G_z = c2d(G_s, 0.5, 'zoh');

[c_new, b_new] = tfdata(G_z, 'v');

for k = 13+step:kk

    y(k) = -b(2)*y(k-1) - b(3)*y(k-2) + c_new(2)*u(k-11-step) + c_new(3)*u(k-12-step);% + disturbance(k);

    d(k) = y(k) - (-b(2)*y(k-1) - b(3)*y(k-2) + c(2)*u(k-11-step) + c(3)*u(k-12-step));

    y_0 = zeros(1, N);

    y_0(1) = -b(2)*y(k) - b(3)*y(k-1) + c(2)*u(k-10-step) + c(3)*u(k-11-step) + d(k);
    y_0(2) = -b(2)*y_0(1) - b(3)*y(k) + c(2)*u(k-9-step) + c(3)*u(k-10-step) + d(k);
    for p=3:N
        if p <= 10
            y_0(p) = -b(2)*y_0(p-1) - b(3)*y_0(p-2) + c(2)*u(k-11+p-step) + c(3)*u(k-12+p-step) + d(k);
        elseif p == 11
            y_0(p) = -b(2)*y_0(p-1) - b(3)*y_0(p-2) + c(2)*u(k-1) + c(3)*u(k-2) + d(k);
        else
            y_0(p) = -b(2)*y_0(p-1) - b(3)*y_0(p-2) + c(2)*u(k-1) + c(3)*u(k-1) + d(k);
        end
    end

    deltauk = K(1, :)*(yzad*ones(1, N) - y_0)';

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

% Computed K values:
% 5.6985 5.5237 5.5047 5.2970 5.1023 4.9229 4.7598 4.6127 4.4807 4.3623 4.2561

figure;
plot([1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2], [5.6985 5.5237 5.5047 5.2970 5.1023 4.9229 4.7598 4.6127 4.4807 4.3623 4.2561]/4)
grid on;
title('Obszar stabilności')
xlabel('T_0/T_0^{nom}')
ylabel('K_0/K_0^{nom}')
