function sim = SimulateSwing3(sys, tspan, event)

    % Before
    delta0 = sys.delta_star;
    omega0 = zeros(sys.n,1);
    x0 = [delta0; omega0];
    P_mech = sys.P_mech;
    K_e = sys.K_e;

    dt_agc = sys.dt_agc;
    agc_times = tspan(1):dt_agc:tspan(2);

    event_times = [event.time];
    [event_times, idx_event_sorted] = sort(event_times);
    event = event(idx_event_sorted);
    all_times = unique([event_times, agc_times]);

    Tcell = {};
    Xcell = {};
    seg = 1;

    t_start = tspan(1);
    x_start = x0;

    odefun = @(t,x) swing_ode(t,x,sys,P_mech,K_e);
    opts = odeset('RelTol',1e-6,'AbsTol',1e-6);

    for k = 1:length(all_times)
        t_end = all_times(k);

        if t_end > t_start
            [t_seg, x_seg] = ode45(odefun, [t_start t_end], x_start, opts);
    
            Tcell{seg} = t_seg;
            Xcell{seg} = x_seg;
            seg = seg + 1;
    
            x_start = x_seg(end,:)';
            if ismember(t_end, agc_times)
                n = sys.n;
                omega_seg = x_seg(:, n+1:end);
                omega_avg = mean(omega_seg,1)';
                tripped = (P_mech == 0);
                KI = sys.KI;
                P_mech(~tripped) = P_mech(~tripped) - KI(~tripped) .* omega_avg(~tripped);
            end
        end
        
        idx_event = find(event_times == t_end);
        if ~isempty(idx_event)
            switch event(idx_event).type
                case "Perturb"
                    x_start(1:sys.n) = x_start(1:sys.n) + event(idx_event).value;
                case "Trip"
                    P_mech(event(idx_event).node) = 0;
                    %P_mech(4) = 2;
                case "LineRemove"
                    K_e(event(idx_event).line) = 0;
            end
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
    
    tripped = (P_mech == 0);
    P_mech_eff = P_mech - sys.R .* omega .* (~tripped)
    
    eta = sys.A * delta;
    XX = (K_e .* sin(eta));
    P_elec = sys.A.' * XX;

    domega = sys.Minv * (P_mech_eff - P_elec - sys.D * omega);
    ddelta = omega;

    dx = [ddelta; domega];

end
