t = linspace(0, 24, 1000);

P0 = 1;
DeltaP = 1;
Omega = 2*pi/24;
phi = pi/2-13*Omega;    % Maximum at t=13...

Pmech = P0 + DeltaP*sin(Omega*t + phi);

figure;
plot(t, Pmech, 'LineWidth', 2);
ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 12;
xlabel('Time of day (hour)', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Mechanical power $P_{mech}(t)$', 'Interpreter', 'latex', 'FontSize', 16);
xlim([0 24]);