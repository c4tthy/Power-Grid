A = 1;
f = 50;
phi = 0;

t = 0:1/(f*1000):0.1;

y = A*sin(2*pi*f*t+phi);

plot(t, y, 'Linewidth', 2);
xlabel('Time', 'FontSize', 16, 'Interpreter', 'latex');
ylabel('Voltage', 'FontSize', 16, 'Interpreter', 'latex');
xlim([0 0.1]);
ylim([-1.5 1.5]);
grid off;
annotation("doublearrow", [0.3628 0.3628], [0.789 0.518]);
a = annotation("textbox", [0.36 0.6699 0.03744 0.05164], "String", "$|V|$", "Interpreter", "latex", "FontSize", 16);
a.EdgeColor='none';
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.YTick = [];
ax.XTick = [];
ax.XAxisLocation = 'origin';
box off;