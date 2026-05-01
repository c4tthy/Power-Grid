function sys = SystemDef()

    sys.A = [1 -1 0 0 0;
             1 0 -1 0 0;
             0 1 -1 0 0;
             0 1 0 -1 0;
             0 0 1 0 -1;
             0 0 0 1 -1];

    [sys.m, sys.n] = size(sys.A);

    sys.P_mech = [1; 0; -1; 1; -1];
    sys.GenIndex = [1 4];
    sys.R = zeros(sys.n,1);
    sys.R(sys.GenIndex) = [5; 5];
    sys.KI = [0.2; 0; 0; 0.2; 0];
    %sys.KI = [0; 0; 0; 0; 0];
    sys.dt_agc = 0.5;

    sys.K_e = [4; 4; 4; 4; 4; 4];
    %sys.K_e = [10; 10; 10; 10; 10; 10];
    %sys.K_e = [0.5; 0.5; 0.5; 0.5; 0.5; 0.5];
    %sys.K_e = [1; 1; 1; 1; 1; 1];
    %sys.K_e = [0.8; 0.8; 0.8; 0.8; 0.8; 0.8];
    sys.K = diag(sys.K_e);

    P_e = pinv(sys.A.') * sys.P_mech;
    sys.P_e = P_e;
    %eta_star = asin(P_e ./ sys.K_e);
    %sys.eta_star = eta_star;

    %A_red = sys.A(:,2:end);
    %delta_red = A_red \ eta_star;
    %sys.delta_star = [0; delta_red];

    sys.M_i = [1; 0.1; 0.1; 1; 0.1];
    sys.D_i = 0.5 * ones(sys.n, 1);
    sys.D_i = [0.75; 0.1; 2; 0.75; 2];

    sys.M = diag(sys.M_i);
    sys.D = diag(sys.D_i);
    sys.Minv = diag(1 ./ sys.M_i);

    sys.P0 = sys.P_mech;
    sys.dP = zeros(sys.n,1);
    sys.dP(1)=1;                      % Comment out to remove the power forcing
    sys.phi = zeros(sys.n,1);
    sys.Omega = 2*pi / 24;

    % Solving Equilibrium.....
    A = sys.A;
    K = sys.K;
    Pmech = sys.P_mech;
    delta = zeros(sys.n,1);
    
    % Newton iteration
    maxIter = 50;
    tol = 1e-12;
    
    for iter = 1:maxIter

    eta = A * delta;
    Pelec = A.' * (K * sin(eta));
    F = Pmech - Pelec;
    F_red = F(2:end);
    if norm(F_red, inf) < tol
        break;
    end

    % Jacobian J = dF/d((delta)
    % J = -A.' * K * diag(cos(eta)) * A
    Jfull = -A.' * (K * diag(cos(eta)) * A);

    J_red = Jfull(2:end, 2:end);

    % Step
    delta_red = delta(2:end) - J_red \ F_red;
    delta = [0; delta_red];
end

sys.delta_star = delta;
sys.eta_star = A * delta;


end