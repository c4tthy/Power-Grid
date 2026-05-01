% Parameters
M      = 5;          % inertia
D      = 1;          % damping
R      = 1;          % droop
kappa  = 0.5;        % AGC gain
Pmax   = 1.0;        % max electrical power
delta0 = asin(0.8);  % Pe0 = 0.8 pu
Pm0    = Pmax * sin(delta0);  % eqm mech power

Delta_delta = 0.1;   % angle pert

tspan = [0 40];

% DROOP
f_droop = @(t,x) [
    x(2);                                            
    ( Pm0 - R*x(2) - Pmax*sin(x(1)) - D*x(2) ) / M   
];

x0_d = [delta0 + Delta_delta; 0];
[td, xd] = ode45(f_droop, tspan, x0_d);

% WithAGC
f_agc = @(t,x) [
    x(2);                                           
    ( Pm0 - R*x(2) - kappa*x(3) - Pmax*sin(x(1)) ...
      - D*x(2) ) / M;                                
    x(2)                                            
];

x0_a = [delta0 + Delta_delta; 0; 0];
[ta, xa] = ode45(f_agc, tspan, x0_a);

figure; hold on; grid on;
plot(td, xd(:,2), 'LineWidth', 2);
plot(ta, xa(:,2), 'LineWidth', 2);
ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 12;

xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Frequency deviation $\omega_i$', 'Interpreter', 'latex', 'FontSize', 16);
legend('Droop only', 'Droop + AGC', 'Interpreter', 'latex', 'FontSize', 12);
