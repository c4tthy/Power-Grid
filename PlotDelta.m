function PlotDelta(sim_nl, sim_lin)

    figure;
    hold on;

    plot(sim_nl.t, sim_nl.delta, 'LineWidth', 2);
    plot(sim_lin.t, sim_lin.delta, '--', 'LineWidth', 1.5);
    
    xlabel('Time', 'Interpreter', 'latex', 'FontSize', 16);
    ylabel('$\delta_i(t)$', 'Interpreter', 'latex', 'FontSize', 16);
    grid on;

    legend_entries = [ ...
        arrayfun(@(i) sprintf('NL $\\delta_%d$',i), 1:size(sim_nl.delta,2), 'UniformOutput', false), ...
        arrayfun(@(i) sprintf('LIN $\\delta_%d$',i), 1:size(sim_lin.delta,2), 'UniformOutput', false) ...
    ];

    legend(legend_entries, 'Interpreter', 'latex', 'FontSize', 12);

end

