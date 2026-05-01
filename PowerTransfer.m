eta = linspace(-pi,pi,500);
K = 1.5;

P = K*sin(eta);

figure
plot(eta,P,'LineWidth',2)
hold on

P0 = 0.6;                                   % Change to scale hw=owever

yline(P0,'k--','LineWidth',2)

% Equilibrium ptz
eta1 = asin(P0/K);
eta2 = pi - eta1;

plot(eta1,P0,'ro','MarkerFaceColor','r','MarkerSize',16)
plot(eta2,P0,'ko','MarkerSize',16)

ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.FontSize = 12;

xline(pi/2,'r--','LineWidth',1.5)
xline(-pi/2,'r--','LineWidth',1.5)

xlabel('$\eta$', 'Interpreter', 'latex', 'FontSize', 16)
ylabel('$P = K \sin(\eta)$', 'Interpreter', 'latex', 'FontSize', 16)

grid on
set(gca,'FontSize',12)
set(gcf,'Color','w')

exportgraphics(gcf,'power_transfer_curve.pdf','ContentType','vector')