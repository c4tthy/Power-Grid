function sim = SimulateSwing2(sys, tspan, event)

    % Before
    delta0 = sys.delta_star;
    omega0 = zeros(sys.n,1);
    x0 = [delta0; omega0];
    P_mech = sys.P_mech;
    K_e = sys.K_e;

    [~, idx] = sort([event.time]);
    event = event(idx);
    
    noevents = numel(event);
    Tcell = cell(noevents+1,1);
    Xcell = cell(noevents+1,1);
    seg = 1;

    t_start = tspan(1);
    x_start = x0;

    odefun = @(t,x) swing_ode(t,x,sys,P_mech,K_e);
    opts = odeset('RelTol',1e-6,'AbsTol',1e-6);

    for k = 1:numel(event)
        t_end = event(k).time;

        if t_end > t_start
            [t_seg, x_seg] = ode45(odefun, [t_start t_end], x_start, opts);
    
            Tcell{seg} = t_seg;
            Xcell{seg} = x_seg;
            seg = seg + 1;
    
            x_start = x_seg(end,:)';
        end
        switch event(k).type
            case "Perturb"
                x_start(1:sys.n) = x_start(1:sys.n) + event(k).value;
            case "Trip"
                P_mech(event(k).node) = 0;
                %P_mech(4) = 2;
            case "LineRemove"
                K_e(event(k).line) = 0;
        end
        odefun = @(t,x) swing_ode(t,x,sys,P_mech,K_e);
        t_start = t_end;
    end
    if tspan(2) > t_start
        [t_seg, x_seg] = ode45(odefun, [t_start tspan(2)], x_start, opts);

        Tcell{seg} = t_seg;
        Xcell{seg} = x_seg;
    end

    T = vertcat(Tcell{:});
    X = vertcat(Xcell{:});
    sim.t     = T;
    sim.delta = X(:,1:sys.n);
    sim.omega = X(:,sys.n+1:end);

end



function dx = swing_ode(~, x, sys,P_mech,K_e)
    
    n = sys.n;
    delta = x(1:n);
    omega = x(n+1:end);

    %P_mech = P_mech - sys.R .* omega;
    
    eta = sys.A * delta;
    XX = (K_e .* sin(eta));
    P_elec = sys.A.' * XX;

    domega = sys.Minv * (P_mech - P_elec - sys.D * omega);
    ddelta = omega;

    dx = [ddelta; domega];

end
