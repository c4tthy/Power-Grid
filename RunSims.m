sys = SystemDef();

tspan = [0 25];
perturb = 0.1 * randn(sys.n,1);
%perturb = [-0.0135; -0.0365; -0.0561; 0.1527; -0.0684];
%perturb = zeros(sys.n,1); 

event = [
    struct('time', 3.0, 'type', "Trip", 'node', [], 'line', [], 'value', zeros(sys.n,1))
    struct('time', 1.0, 'type', "LineRemove", 'node', [], 'line', [], 'value', zeros(sys.n,1))
    struct('time', 1.0, 'type', "LineRemove", 'node', [], 'line', [], 'value', zeros(sys.n,1))
    struct('time', 2.0, 'type', "Perturb", 'node', [], 'line', [], 'value', perturb)
];

%StaticNetwork(sys)
sim_nl = SimulateSwing(sys, tspan, perturb, event, 1.0);
sim_lin = SimulateLinear(sys, tspan, perturb, event, 1.0);
%sim_nl = SimulateSwing3(sys, tspan, event);
%sim_lin = SimulateLinear(sys, tspan, event);


PlotOmega(sim_nl, sim_lin);
PlotDelta(sim_nl, sim_lin);
PlotEta(sys, sim_nl, sim_lin);
PlotDelta(sim_nl, sim_lin);

AnimatedNetwork(sys, sim_nl, event);

% omega -> loss of P_mech / Sum D_i

