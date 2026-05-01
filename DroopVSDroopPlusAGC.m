% Parameters
M     = 5;      % inertia
D     = 1;      % damping
R     = 1;      % droop
kappa = 0.5;    % AGC gain
DeltaP = 0.1;   % load step

tspan = [0 50];

% Droop only
f_droop = @(t,x) [
    x(2);                                     
    ( -DeltaP - (D+R)*x(2) ) / M
];

x0_d = [0; 0]; 
[td, xd] = ode45(f_droop, tspan, x0_d);

% AGC as well
f_agc = @(t,x) [
    x(2);                                      
    ( -DeltaP - (D+R)*x(2) - kappa*x(3) ) / M; 
    x(2)                                       
];

x0_a = [0; 0; 0];
[ta, xa] = ode45(f_agc, tspan, x0_a);

figure; hold on; grid on;

plot(td, xd(:,2), 'LineWidth', 2);
plot(ta, xa(:,2), 'LineWidth', 2);
ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 12;

xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Frequency deviation $\omega_i$', 'Interpreter', 'latex', 'FontSize', 16);
legend('Droop only', 'Droop and AGC', 'Interpreter', 'latex', 'FontSize', 12);