K_0 = 4;
T_0 = 5;
T_1 = 1.69;
T_2 = 5.36;
Tp = 0.5;

G_s = tf(K_0, [T_1*T_2, T_1 + T_2, 1], 'InputDelay', T_0);

G_z = c2d(G_s, Tp, 'zoh');

[c, b] = tfdata(G_z, 'v');

y_fun = @(k, y, u) (-b(2)*y(k-1) - b(3)*y(k-2) + c(2)*u(k-11) + c(3)*u(k-12));

kk = 200;

wy_u_gpc = zeros(1, kk);
wy_y_gpc = zeros(1, kk);
yzad = 1;

s = step(G_z);
s(1) = [];

D = 92;
N = 20;
Nu = 1;

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

dist(1:40) = 0;
dist(41: kk) = 0.2;
d = zeros(1, kk);

y(1:12) = 0;
u(1:12) = 0;

for k = 13:kk
    y(k) = y_fun(k, y, u); % + dist(k);

    d(k) = y(k) - y_fun(k, y, u);

    y_0 = zeros(1, N);

    y_0(1) = -b(2)*y(k) - b(3)*y(k-1) + c(2)*u(k-10) + c(3)*u(k-11) + d(k);
    y_0(2) = -b(2)*y_0(1) - b(3)*y(k) + c(2)*u(k-9) + c(3)*u(k-10) + d(k);
    for p=3:N
        if p <= 10
            y_0(p) = -b(2)*y_0(p-1) - b(3)*y_0(p-2) + c(2)*u(k-11+p) + c(3)*u(k-12+p) + d(k);
        else
            y_0(p) = -b(2)*y_0(p-1) - b(3)*y_0(p-2) + c(2)*u(k-1) + c(3)*u(k-1) + d(k);
        end
    end

    deltauk = K(1, :)*(yzad*ones(1, N) - y_0)';

    u(k) = u(k-1) + deltauk;

    wy_u_gpc(k) = u(k);
    wy_y_gpc(k) = y(k);
end

figure;
stairs(0:kk, [0 wy_u_gpc]); hold on; grid on;
xlabel('k'); title('u');

figure;
stairs(0:kk, [0 yzad*ones(1, kk)]);
hold on; grid on;
stairs(1:kk, wy_y_gpc);
xlabel('k'); title('y, yzad');
