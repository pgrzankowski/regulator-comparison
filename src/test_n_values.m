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

N_values = [15, 17, 20]; % Different values of N to test
Nu = 2;
lambda = 1;
y_zad = 1;

figure; hold on; grid on;
xlabel('k'); title('u');
u_legends = cell(1, length(N_values));

figure; hold on; grid on;
xlabel('k'); title('y, yzad');
stairs(0:kk, [0 y_zad*ones(1, kk)], 'r--');

for idx = 1:length(N_values)
    N = N_values(idx);
    
    wy_u = zeros(1, kk);
    wy_y = zeros(1, kk);

    s = step(G_z);
    s(1) = [];
    D = length(s);

    y = zeros(1, kk);
    u = zeros(1, kk);

    deltaupk = zeros(1, D-1);

    M = zeros(N, Nu);

    for i = 1:N
        for j = 1:Nu
            if i >= j
                M(i, j) = s(i-j+1);
            end
        end
    end

    MP = zeros(N, D-1);

    for i = 1:N
        for j = 1:D-1
            if i + j <= D
                MP(i, j) = s(i+j) - s(j);
            else
                MP(i, j) = s(D) - s(j);
            end
        end
    end

    I = eye(Nu);
    K = (M' * M + lambda * I) \ M';
    Ku = K(1, :) * MP;
    Ke = sum(K(1, :));

    for k = 13:kk
        y(k) = y_fun(k, y, u);

        ek = y_zad - y(k);

        deltauk = Ke * ek - Ku * deltaupk';

        for n = D-1:-1:2
            deltaupk(n) = deltaupk(n-1);
        end

        deltaupk(1) = deltauk;

        u(k) = u(k-1) + deltauk;

        wy_u(k) = u(k);
        wy_y(k) = y(k);
    end

    figure(1);
    stairs(0:kk, [0 wy_u]); 
    u_legends{idx} = ['N = ' num2str(N)];

    figure(2);
    plot(1:kk, wy_y); 
end

figure(1);
legend(u_legends);
xlabel('k'); title('Control Signal u');
hold off;

figure(2);
legend(['Reference', u_legends]);
xlabel('k'); title('System Output y');
hold off;
