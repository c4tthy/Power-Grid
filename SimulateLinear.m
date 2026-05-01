function lin = SimulateLinear(sys, tspan, perturb, event, t_p)
    


    A = sys.A;
    K = sys.K;
    M = sys.M;
    D = sys.D;
    delta_star = sys.delta_star;
    n = sys.n;

    % Linearising shocker

    eta_star = A * delta_star;
    J_e = diag(sys.K_e .* cos(eta_star));
    L = A' * J_e * A;

    Z = zeros(n);
    I = eye(n);
    A_lin = [ Z,      I;
             -M\L, -M\D ];

    % ICs (change=0)
    delta0 = delta_star;
    omega0 = zeros(n,1);
    x0 = [delta0 - delta_star; omega0];

    % Before perturbation
    odefun = @(t,x) linear_ode(t, x, A_lin, sys, event);
    [t1, x1] = ode45(odefun, [tspan(1) t_p], x0);

    % At perturbation
    x_p = x1(end,:)';
    x_p(1:n) = x_p(1:n) + perturb;   % Δδ += perturb

    % After perturbation
    [t2, x2] = ode45(odefun, [t_p tspan(2)], x_p);

    % Put together
    lin.t = [t1; t2(2:end)];
    lin.delta = [x1(:,1:n); x2(2:end,1:n)] + delta_star';
    lin.omega = [x1(:,n+1:end); x2(2:end,n+1:end)];

end


function dx = linear_ode(t, x, A_lin, sys, event)

    P_mech = sys.P_mech;
    K_e = sys.K_e;
    for k = 1:numel(event)
        ev = event(k);
        if t >= ev.time && ev.type == "Trip"
            P_mech(ev.node) = 0;
        end
        if t >= ev.time && ev.type == "LineRemove"
            K_e(ev.line) = 0;
        end
    end

    dP = P_mech - sys.P_mech;

    B = [zeros(sys.n, 1); sys.Minv * dP];

    dx = A_lin * x + B;

end
