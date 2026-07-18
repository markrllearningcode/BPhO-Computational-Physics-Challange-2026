function brownian_motion()
  % Brownian motion simulation
  % N small particles of mass m, radius r moving randomly
  % One large particle of mass M, radius R starting from rest
  % Units: nm for position, ps for time and nm/ps for velocity

  % Simulation parameters
  dt = 0.5; % timestep (ps)
  box_size = 200; % box width and height (nm)
  bounds = [0 box_size 0 box_size];
  steps_per_frame = 5;
  Kn = 10; % Knudsen number which randomises direction every Kn radii

  % Elastic/Inelastic toggle
  elastic_mode = true;
  C_elastic = 1.0;
  C_inelastic = 0.7;
  C = C_elastic;

  % Small Particles
  N = 100; % number of particles
  m = 1.0; % mass of small particle
  r = 1.5; % radius of small particle in nm
  speed = 2.0; % fixed speed of small particles in nm/ps

  % Large Particle
  M = 20.0; % mass of large particle
  R = 10.0; % radius of large particle
  P = [box_size/2, box_size/2]; % start from centre_of_mass
  V = [0,0]; % starts from rest

  %initialize small particles randomly (not overlapping with other particles)
  px = zeros(N, 1);
  py = zeros(N, 1);
  vx = zeros(N, 1);
  vy = zeros(N, 1);
  step_counter = zeros(N, 1); % counts steps since last direction randomise

  for i = 1:N
    while true
      px(i) = r + rand * (box_size - 2*r);
      py(i) = r + rand * (box_size - 2*r);
      % make sure it doesn't start inside the large particle
      if norm([px(i) - P(1), py(i) - P(2)]) > R + r + 1
        break;
      endif
    endwhile
    theta = 2 * pi * rand;
    vx(i) = speed * cos(theta);
    vy(i) = speed * sin(theta);
    step_counter(i) = round(rand * Kn * r / (speed * dt)); % stagger initial randomization
  endfor

  % Trail for large particle
  trail_x = P(1);
  trail_y = P(2);
  start_pos = P;

  % Figure setup
  fig = figure('Name', 'Brownian Motion Simulation', 'NumberTitle', 'off', 'Color', [1 1 1]);
  axis equal;
  axis(bounds);
  set(gca, 'xtick', [], 'ytick', []);
  box on;
  hold on;

  % Draw boundary
  rectangle('Position', [0, 0, box_size, box_size], 'EdgeColor', 'k', 'LineWidth', 2);

  % Draw Small particles as dots
  h_small = plot(px, py, 'b.', 'MarkerSize', 6);

  % Draw Trail
  h_trail = plot(trail_x, trail_y, 'r-', 'LineWidth', 1);

  % Start marker -> green star
  h_start = plot(start_pos(1), start_pos(2), 'g*', 'MarkerSize', 10, 'LineWidth', 2);

  % Large particle circle
  h_large = rectangle('Position', [P(1)-R, P(2)-R, 2*R, 2*R], 'Curvature', [1 1], 'EdgeColor', 'r', 'LineWidth', 2.5);

  % Current position marker -> red star
  h_curr = plot(P(1), P(2), 'r*', 'MarkerSize', 10, 'LineWidth', 2);

  % Time and mode text
  t_text = text(box_size/2, box_size - 5, '', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10);

  t = 0;
  set(fig, 'KeyPressFcn', @onKey);
  setappdata(fig, 'quit', false);

  % Main Loop
  while ishandle(fig) && ~getappdata(fig, 'quit')
    for s = 1:steps_per_frame

      % Move small particles
      px = px + vx * dt;
      py = py + vy * dt;
      step_counter = step_counter + 1;

      % Randomize small particle directions every Kn*r distance
      steps_to_randomise = round(Kn * r / (speed * dt));
      for i = 1:N
        if step_counter(i) >= steps_to_randomise
          theta = 2 * pi * rand;
          vx(i) = speed * cos(theta);
          vy(i) = speed * sin(theta);
          step_counter(i) = 0;
        endif
      endfor

      % wall collisions for small particles
      % Left/Right
      left_hit = (px - r < 0)   & (vx < 0);
      right_hit = (px + r > box_size)   & (vx > 0);
      px(left_hit) = r;
      px(right_hit) = box_size - r;
      vx(left_hit | right_hit) = -C * vx(left_hit | right_hit);

      % Up/Down
      bot_hit = (py - r < 0)    & (vy < 0);
      top_hit = (py + r > box_size)   & (vy > 0);
      py(bot_hit) = r;
      py(top_hit) = box_size - r;
      vy(bot_hit | top_hit) = -C * vy(bot_hit | top_hit);

      % Move large particle
      P = P + V * dt;

      % Wall collissions for large particle
      if (P(1) - R < 0) && (V(1) < 0)
        P(1) = R;
        V(1) = -C * V(1);
      elseif (P(1) + R > box_size) && (V(1) > 0)
        P(1) = box_size - R;
        V(1) = -C * V(1);
      endif
      if (P(2) - R < 0) && (V(2) < 0)
        P(2) = R;
        V(2) = -C * V(2);
      elseif (P(2) + R > box_size) && (V(2) > 0)
        P(2) = box_size - R;
        V(2) = -C * V(2);
      endif

      % Small-Large particle collisions (ZMF method from the task sheet)
      for i = 1:N
        dp = [px(i) - P(1), py(i) - P(2)];
        dist = norm(dp);
        minDist = R + r;

        if dist < minDist && dist > 1e-12
          n_hat = dp / dist;

          % Veocitites of small and large particles
          u1 = V; % larger particle velocity
          u2 = [vx(i), vy(i)]; % small particle velocity

          % ZMF Veocity
          Vcm = (M * u1 + m * u2) / (M + m);

          % Post collision velocities usng ZMF + restitution C
          v1_new = C * (Vcm - u1) + Vcm;
          v2_new = C * (Vcm - u2) + Vcm;

          % Seperate overlapping particles
          overlap = minDist - dist;
          P = P - (m/(M+m)) * overlap * n_hat;
          px(i) = px(i) + (M/(M+m)) * overlap * n_hat(1);
          py(i) = py(i) + (M/(M+m)) * overlap * n_hat(2);
          V = v1_new;
          vx(i) = v2_new(1);
          vy(i) = v2_new(2);
        endif
      endfor

      % Record trail
      trail_x(end+1) = P(1);
      trail_y(end+1) = P(2);
    endfor

    % Update graphics
    set(h_small, 'XData', px, 'YData', py);
    set(h_trail, 'XData', trail_x, 'YData', trail_y);
    set(h_large, 'Position', [P(1)-R, P(2)-R, 2*R, 2*R]);
    set(h_curr, 'XData', P(1), 'YData', P(2));

    mode_str = 'inelastic';
    if elastic_mode, mode_str = 'elastic';
  endif
  set(t_text, 'String', sprintf('t = %.1f ps [%s] (E = Toggle, Q = quit)', t, mode_str));
  t += dt * steps_per_frame;

  drawnow();
  endwhile

  % Compute MSD of large particle
  n_trail = length(trail_x);
  max_lag = floor(n_trail / 2 );
  lags = 1:max_lag;
  msd = zeros(1, max_lag);

  for lag = lags
    dx = trail_x(1+lag:end) - trail_x(1:end-lag);
    dy = trail_y(1+lag:end) - trail_y(1:end-lag);
    msd(lag) = mean(dx.^2 + dy.^2);
  endfor

  time_lags = lags * dt * steps_per_frame;

  figure;
  plot(time_lags, msd, 'b-', 'LineWidth', 1.5);
  xlabel('Time lag (ps)');
  ylabel('MSD (nm^2)');
  title('Mean Square Displacement of Large Particle');
  grid on;
  box on;
  print(gcf, 'brownian_msd.png', '-dpng', '-r300');

  % Save Final trail figure
  figure;
  plot(trail_x, trail_y, 'r-', 'LineWidth', 1);
  hold on;
  plot(trail_x(1), trail_y(1), 'g*', 'MarkerSize', 12, 'LineWidth', 2);
  plot(trail_x(end), trail_y(end), 'r*', 'MarkerSize', 12, 'LineWidth', 2);
  xlabel('x (nm)');
  ylabel('y (nm)');
  title('Trail of large particle (Brownian Motion)');
  legend('Trail', 'Start', 'End', 'Location', 'northeast');
  grid on;
  box on;
  axis equal;
  print(gcf, 'brownian_motion.png', '-dpng', '-r300');

  function onKey(~, evt)
    key = evt.Key;
    if strcmp(key, 'q')
      setappdata(fig, 'quit', true);
      return;
    endif
    if strcmp(key, 'e')
      elastic_mode = ~elastic_mode;
      if elastic_mode
        C = C_elastic;
      else
        C = C_inelastic;
      endif
    endif
  endfunction
endfunction
