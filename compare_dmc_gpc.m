run('dmc.m');
run('gpc.m');

figure;
stairs(0:kk, [0 wy_u_dmc]);
hold on; grid on;
stairs(0:kk, [0 wy_u_gpc]);
xlabel('k'); title('u');
legend('dmc', 'gpc')
hold off;

figure;
stairs(0:kk, [0 y_zad*ones(1, kk)]);
hold on; grid on;
plot(1:kk, wy_y_dmc);
plot(1:kk, wy_y_gpc);
xlabel('k'); title('y, yzad');
legend('y_{zad}', 'dmc', 'gpc')
hold off;
