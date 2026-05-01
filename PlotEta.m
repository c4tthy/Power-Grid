function PlotEta(sys, sim_nl, sim_lin)

    A = sys.A;
    delta_nl = sim_nl.delta;
    delta_lin = sim_lin.delta;

    eta_nl = (A * delta_nl.').';
    eta_lin = (A * delta_lin.').';


    figure;
    hold on;


    plot(sim_nl.t, eta_nl, 'LineWidth', 2);
    plot(sim_lin.t, eta_lin, '--', 'LineWidth', 1.5);

    xlabel('Time', 'Interpreter', 'latex', 'FontSize', 16);
    ylabel('$\eta_e(t)$', 'Interpreter', 'latex', 'FontSize', 16);
    grid on;

    legend_entries = [ ...
        arrayfun(@(i) sprintf('NL $\\eta_%d$',i), 1:size(eta_nl,2), 'UniformOutput', false), ...
        arrayfun(@(i) sprintf('LIN $\\eta_%d$',i), 1:size(eta_lin,2), 'UniformOutput', false) ...
    ];

    legend(legend_entries, 'Interpreter', 'latex', 'FontSize', 12);
end
