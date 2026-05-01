clear; clc; close all;

mpc = loadcase('case9');
results = runpf(mpc);

theta_deg = results.bus(:, 9);     % column 9 = voltage angle in degrees
theta = deg2rad(theta_deg);             % need rad

% Randm gen of the angles
phi = 2*pi*rand(9,1);

r_complex = mean(exp(1j * theta));
r = abs(r_complex);
rr_complex = mean(exp(1j * phi));
rr = abs(rr_complex);
angletheta = angle(r_complex);
anglephi = angle(rr_complex);

fprintf('Kuramoto order parameter r = %.4f\n', r);

figure; hold on; axis equal;
th = linspace(0, 2*pi, 400);
plot(cos(th), sin(th), 'k--');  % unit circle

for i = 1:length(theta)
    plot(cos(theta(i)), sin(theta(i)), 'o', 'MarkerSize', 16, 'LineWidth', 2);
    %text(1.1*cos(theta(i)), 1.1*sin(theta(i)), sprintf('Bus %d', i));
end
ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 12;
%title(sprintf('IEEE 9-Bus Phase Angles (r = %.3f)', r));
xlabel('Re', 'Interpreter', 'latex', 'FontSize', 16); ylabel('Im', 'Interpreter', 'latex', 'FontSize', 16);
grid on;

quiver(0, 0, r*cos(angletheta), r*sin(angletheta), ...
    'LineWidth', 2, 'MaxHeadSize', 0.5, 'Color', 'r');

text(1.1*r*cos(angletheta), 1.1*r*sin(angletheta), sprintf('r = %.3f', r), ...
    'Color', 'r', 'FontWeight', 'bold', 'Interpreter', 'latex', 'FontSize', 16);


figure; hold on; axis equal;
th = linspace(0, 2*pi, 400);
plot(cos(th), sin(th), 'k--');  % unit circle

for i = 1:length(phi)
    plot(cos(phi(i)), sin(phi(i)), 'o', 'MarkerSize', 16, 'LineWidth', 2);
end
ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 12;
xlabel('Re', 'Interpreter', 'latex', 'FontSize', 16); ylabel('Im', 'Interpreter', 'latex', 'FontSize', 16);
grid on;

quiver(0, 0, rr*cos(anglephi), rr*sin(anglephi), ...
    'LineWidth', 2, 'MaxHeadSize', 0.5, 'Color', 'r');

text(1.1*rr*cos(anglephi), 1.1*rr*sin(anglephi), sprintf('r = %.3f', rr), ...
    'Color', 'r', 'FontWeight', 'bold', 'Interpreter', 'latex', 'FontSize', 16);
