function PlotOmega(sim_nl, sim_lin)

    figure;
    hold on;

    plot(sim_nl.t, sim_nl.omega, 'LineWidth', 2);
    plot(sim_lin.t, sim_lin.omega, '--', 'LineWidth', 1.5);
    
    xlabel('Time', 'Interpreter', 'latex', 'FontSize', 16);
    ylabel('$\omega_i(t)$', 'Interpreter', 'latex', 'FontSize', 16);
    grid on;

    legend_entries = [ ...
        arrayfun(@(i) sprintf('NL $\\omega_%d$',i), 1:size(sim_nl.omega,2), 'UniformOutput', false), ...
        arrayfun(@(i) sprintf('LIN $\\omega_%d$',i), 1:size(sim_lin.omega,2), 'UniformOutput', false) ...
    ];

    legend(legend_entries, 'Interpreter', 'latex', 'FontSize', 12);

end

