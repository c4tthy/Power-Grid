function StaticNetwork(sys)

A = sys.A;
P_mech_node = sys.P_mech;
K_e = sys.K_e;

delta_eq = sys.delta_star;   % equilibrium delta_i
omega_eq = 0;   % equilibrium omega_i (usually zero)
m = sys.m;
n = sys.n;

[edge_idx, src] = find(A == 1);
[~, dst] = find(A == -1);
G = graph(src, dst);

% Same as the animated one but just ob not
temp = plot(G, 'Layout', 'force');
nodeX = temp.XData;
nodeY = temp.YData;
close(gcf);

numEdges = numedges(G);

% Midpoints
edge_mid_x = zeros(numEdges,1);
edge_mid_y = zeros(numEdges,1);
edge_dx = zeros(numEdges,1);
edge_dy = zeros(numEdges,1);

for e = 1:numEdges
    i = src(e);
    j = dst(e);

    x1 = nodeX(i);  y1 = nodeY(i);
    x2 = nodeX(j);  y2 = nodeY(j);

    edge_mid_x(e) = (x1 + x2)/2;
    edge_mid_y(e) = (y1 + y2)/2;

    edge_dx(e) = x2 - x1;
    edge_dy(e) = y2 - y1;
end

% Flow
flows = zeros(numEdges,1);
for e = 1:numEdges
    flows(e) = K_e(e) * sin(delta_eq(src(e)) - delta_eq(dst(e)));
end

% Nodes
gen_nodes  = find(P_mech_node > 0);
load_nodes = find(P_mech_node < 0);
sub_nodes  = find(P_mech_node == 0);


figure('Position',[100 100 1200 600]);

subplot(1,2,1);
hold on; axis off;

plot(G, 'XData', nodeX, 'YData', nodeY, ...
     'LineWidth', 3, 'NodeLabel', []);


for i = 1:n
    text(nodeX(i), nodeY(i), sprintf('%d', i), ...
         'HorizontalAlignment','left', ...
         'VerticalAlignment','top', ...
         'FontSize',14, 'FontWeight','bold');
end

% Scatter Stuff
cmin_delta = min(delta_eq);
cmax_delta = max(delta_eq);

h_gen = scatter(nodeX(gen_nodes), nodeY(gen_nodes), 200, "s", "filled");
h_load = scatter(nodeX(load_nodes), nodeY(load_nodes), 200, "o", "filled");
h_sub = scatter(nodeX(sub_nodes), nodeY(sub_nodes), 200, "^", "filled");

h_gen.CData = delta_eq(gen_nodes);
h_load.CData = delta_eq(load_nodes);
h_sub.CData = delta_eq(sub_nodes);

colormap(hsv);
colorbar;
clim([cmin_delta cmax_delta]);

% Arrows
arrow_scale = 0.2;
for e = 1:numEdges
    dx = edge_dx(e);
    dy = edge_dy(e);
    L = sqrt(dx^2 + dy^2);
    ux = dx / L;
    uy = dy / L;

    mag = arrow_scale * abs(flows(e));

    if flows(e) >= 0
        ax = ux * mag;
        ay = uy * mag;
    else
        ax = -ux * mag;
        ay = -uy * mag;
    end

    quiver(edge_mid_x(e), edge_mid_y(e), ax, ay, ...
           'MaxHeadSize', 2, 'Color', 'k', 'LineWidth', 3);
end

end
