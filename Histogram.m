clear; close all; clc

define_constants

mpc = loadcase('case9')
results = runpf(mpc);

V = results.bus(:,VM);
delta = results.bus(:,VA)*pi/180;

from = results.branch(:,F_BUS);
to   = results.branch(:,T_BUS);
x    = results.branch(:,BR_X);

nb = length(V);
nl = length(from);

A = zeros(nl,nb);
for e = 1:nl
    A(e,from(e)) = 1;
    A(e,to(e)) = -1;
end

eta_star = A*delta;

figure
histogram(eta_star,10)

hold on
xline(pi/2,'r--','LineWidth',1.5)
xline(-pi/2,'r--','LineWidth',1.5)

ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 12;

xlabel('$\eta_e^*$', 'Interpreter', 'latex', 'FontSize', 16)
ylabel('Number of lines', 'Interpreter', 'latex', 'FontSize', 16)

grid on
set(gca,'FontSize',12)
set(gcf,'Color','w')

exportgraphics(gcf,'eta_distribution.pdf','ContentType','vector')