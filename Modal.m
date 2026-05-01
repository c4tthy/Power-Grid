clear; close all; clc

define_constants

mpc = loadcase('case9');
results = runpf(mpc);

V = results.bus(:,VM);
delta = results.bus(:,VA)*pi/180;

from = results.branch(:,F_BUS);
to   = results.branch(:,T_BUS);
x    = results.branch(:,BR_X);

nb = length(V);
nl = length(from);

% Incidence matrix
A = zeros(nl,nb);
for e = 1:nl
    A(e,from(e)) = 1;
    A(e,to(e)) = -1;
end

% coupling
K = zeros(nl,1);
for e = 1:nl
    i = from(e);
    j = to(e);
    K(e) = V(i)*V(j)/x(e);
end

Kmat = diag(K);

eta_star = A*delta;
J = diag(cos(eta_star));
LKJ = A'*Kmat*J*A;

M = diag([6 6 6 6 6 6 6 6 6]);              % Inertial params - can change


[U,Mu] = eig(LKJ,M);
mu = diag(Mu);

figure
stem(sort(mu),'filled', 'MarkerSize', 12, 'LineWidth', 1.5)

ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 12;

xlabel('Mode index', 'Interpreter', 'latex', 'FontSize', 16)
ylabel('$\mu_i$', 'Interpreter', 'latex', 'FontSize', 16)

grid on
set(gca,'FontSize',12)
set(gcf,'Color','w')

exportgraphics(gcf,'modal_spectrum.pdf','ContentType','vector')