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

wy_u_dmc = zeros(1, kk);
wy_y_dmc = zeros(1, kk);
y_zad = 1;

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

dist(1:40) = 0;
dist(41: kk) = 0.2;

for k=13:kk
    y(k) = y_fun(k, y, u); % + dist(k);

    ek = y_zad - y(k);

    deltauk = Ke * ek - Ku * deltaupk';

    for n=D-1:-1:2
        deltaupk(n) = deltaupk(n-1);
    end

    deltaupk(1) = deltauk;

    u(k) = u(k-1) + deltauk;

    wy_u_dmc(k) = u(k);
    wy_y_dmc(k) = y(k);
end


figure;
stairs(0:kk, [0 wy_u_dmc]); hold on; grid on;
xlabel('k'); title('u');

figure;
stairs(0:kk, [0 y_zad*ones(1, kk)]);
hold on; grid on;
stairs(1:kk, wy_y_dmc);
xlabel('k'); title('y, yzad');