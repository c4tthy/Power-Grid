function sim = SimulateSwing(sys, tspan, perturb, event, t_p)

    % Before
    delta0 = sys.delta_star;
    omega0 = zeros(sys.n,1);
    x0 = [delta0; omega0];

    odefun = @(t,x) swing_ode(t,x,sys,event);
    opts = odeset('RelTol',1e-6,'AbsTol',1e-6);

    [t1,x1] = ode45(odefun, [tspan(1) t_p], x0, opts);

    % Perturbation
    x_p = x1(end,:)';
    x_p(1:sys.n) = x_p(1:sys.n) + perturb;

    % After
    [t2,x2] = ode45(odefun, [t_p tspan(2)], x_p, opts);

    % Together
    sim.t     = [t1; t2(2:end)];
    sim.delta = [x1(:,1:sys.n); x2(2:end,1:sys.n)];
    sim.omega = [x1(:,sys.n+1:end); x2(2:end,sys.n+1:end)];
    

end



function dx = swing_ode(t, x, sys, event)
    
    n = sys.n;
    delta = x(1:n);
    omega = x(n+1:end);

    P_mech = sys.P_mech;

    P_forcingpart = sys.dP(1) .* sin(sys.Omega * t + sys.phi(1));
    P_mech(1) = sys.P0(1) + P_forcingpart;
    P_mech(4) = sys.P0(4) - P_forcingpart;


    K_e = sys.K_e;

    isTripped = false(sys.n,1);
    for k = 1:numel(event)
        ev = event(k);
        if t >= ev.time && ev.type == "Trip"
            P_mech(ev.node) = 0;
            isTripped(ev.node) = true;
        end
        if t >= ev.time && ev.type == "LineRemove"
            K_e(ev.line) = 0;
        end
    end
    % for i = sys.GenIndex(:)'
    %     if ~isTripped(i)
    %         P_mech(i) = sys.P_mech(i) - sys.R(i) * omega(i);
    %     end
    % end
    eta = sys.A * delta;
    K = diag(K_e);
    P_elec = sys.A.' * (K * sin(eta));

    domega = sys.Minv * (P_mech - P_elec - sys.D * omega);
    ddelta = omega;

    dx = [ddelta; domega];

end
