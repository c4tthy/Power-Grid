function AnimatedNetwork(sys, sim, event)

A = sys.A;
P_mech_node = sys.P_mech;
K_e = sys.K_e;

delta_t = sim.delta;
omega_t = sim.omega;
t = sim.t;

m = sys.m;
n = sys.n;

% Produces the graph
[edge_idx, src] = find(A == 1);
[~, dst] = find(A == -1);
G = graph(src, dst);

% Resampling for the video: change frames per second
video_fps = 1;
t_video = 0 : 1/video_fps : t(end);

[t_unique, ia] = unique(t);
delta_t_unique = delta_t(ia,:);
omega_t_unique = omega_t(ia,:);

delta_video = interp1(t_unique, delta_t_unique, t_video);
omega_video = interp1(t_unique, omega_t_unique, t_video);

% Colour scales go from the minimum to maximum delta or omega
cmin_delta = min(delta_t(:));
cmax_delta = max(delta_t(:));

cmin_omega = min(omega_t(:));
cmax_omega = max(omega_t(:));

% Set the nodes in place
temp = plot(G, 'Layout', 'force');
nodeX = temp.XData;
nodeY = temp.YData;
close(gcf);

% Compute edge midpoints (for the arrows)
numEdges = numedges(G);
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

% Produce figure
fig = figure('Position',[100 100 1200 600]);

% Left pic
subplot(1,2,1);
hold on;
title('Node Angles \delta_i');
axis off;

plot(G, 'XData', nodeX, 'YData', nodeY, 'LineWidth', 3, 'NodeLabel', []);


% Node numbers
for i = 1:n
    text(nodeX(i), nodeY(i), sprintf('%d', i), ...
         'HorizontalAlignment','left', ...
         'VerticalAlignment','top', ...
         'FontSize',14, 'FontWeight','bold', 'Color','k');
end

colormap(hsv);
colorbar;
clim([cmin_delta cmax_delta]);

% Arrows for left pic
arrow_scale = 0.2;
arrows1 = gobjects(numEdges,1);
for e = 1:numEdges
    arrows1(e) = quiver(edge_mid_x(e), edge_mid_y(e), 0, 0, ...
                        'MaxHeadSize', 2, 'Color', 'k', 'LineWidth', 3);
end

% Right pic
subplot(1,2,2);
hold on;
title('Node Frequencies \omega_i');
axis off;

plot(G, 'XData', nodeX, 'YData', nodeY, 'LineWidth', 3, 'NodeLabel', []);

% Node numbers
for i = 1:n
    text(nodeX(i), nodeY(i), sprintf('%d', i), ...
         'HorizontalAlignment','left', ...
         'VerticalAlignment','top', ...
         'FontSize',14, 'FontWeight','bold', 'Color','k');
end

colormap(hsv);
colorbar;
clim([cmin_omega cmax_omega]);

% Arrows on right pic
arrows2 = gobjects(numEdges,1);
for e = 1:numEdges
    arrows2(e) = quiver(edge_mid_x(e), edge_mid_y(e), 0, 0, ...
                        'MaxHeadSize', 2, 'Color', 'k', 'LineWidth', 3);
end

% Video
v = VideoWriter('swing_dynamics.mp4', 'MPEG-4');
v.FrameRate = video_fps;
open(v);

% Loop for each
for k = 1:length(t_video)
    
    t_now = t_video(k);
    P_mech_now = P_mech_node;
    K_e_now = K_e;
    for j = 1:numel(event)
        ev = event(j);
        if t_now >= ev.time && ev.type == "Trip"
            P_mech_now(ev.node) = 0;
        end
        if t_now >= ev.time && ev.type == "LineRemove"
            K_e_now(ev.line) = 0;
        end
    end
    gen_nodes  = find(P_mech_now > 0);
    load_nodes = find(P_mech_now < 0);
    sub_nodes  = find(P_mech_now == 0);



    % Left pic
    subplot(1,2,1);
    node_colors = delta_video(k,:);


    % Delete and recreate scatters
    delete(findobj(gca, "Type", "Scatter"));
    h_gen1 = scatter(nodeX(gen_nodes), nodeY(gen_nodes), 200, "s", "filled");
    h_load1 = scatter(nodeX(load_nodes), nodeY(load_nodes), 200, "o", "filled");
    h_sub1 = scatter(nodeX(sub_nodes), nodeY(sub_nodes), 200, "^", "filled");
    h_gen1.CData = node_colors(gen_nodes);
    h_load1.CData = node_colors(load_nodes);
    h_sub1.CData = node_colors(sub_nodes);

    title(sprintf('$\\delta_i(t)$, $t = %.2f$', mod(t_now+7,24)), 'Interpreter', 'latex', 'FontSize', 16);

    % Update arrows
    for e = 1:numEdges
        flow = K_e_now(e) * sin(delta_video(k,src(e)) - delta_video(k,dst(e)))
        dx = edge_dx(e);
        dy = edge_dy(e);
        L = sqrt(dx^2 + dy^2);
        ux = dx / L;
        uy = dy / L;

        mag = arrow_scale * abs(flow);
        
        if flow >= 0
            ax = ux * mag;
            ay = uy * mag;
        else
            ax = -ux * mag;
            ay = -uy * mag;
        end

        arrows1(e).UData = ax;
        arrows1(e).VData = ay;
        arrows2(e).UData = ax;
        arrows2(e).VData = ay;
    end

    % Right pic
    subplot(1,2,2);
    node_colors = omega_video(k,:);
    

    % Delete and recreate scatters? Surely don't need to? wtvr
    delete(findobj(gca, "Type", "Scatter"));
    h_gen2 = scatter(nodeX(gen_nodes), nodeY(gen_nodes), 200, "s", "filled");
    h_load2 = scatter(nodeX(load_nodes), nodeY(load_nodes), 200, "o", "filled");
    h_sub2 = scatter(nodeX(sub_nodes), nodeY(sub_nodes), 200, "^", "filled");
    h_gen2.CData = node_colors(gen_nodes);
    h_load2.CData = node_colors(load_nodes);
    h_sub2.CData = node_colors(sub_nodes);

    title(sprintf('$\\omega_i(t)$, $t = %.2f$', mod(t_now+7,24)), 'Interpreter', 'latex', 'FontSize', 16);

    % Write frame
    frame = getframe(fig);
    writeVideo(v, frame);
end

close(v);
disp('Video saved as swing_dynamics.mp4');

end
