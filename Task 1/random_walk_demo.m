%Random walk demo.
%Take a fixed step of L meters. Between each step, change direction randomly
% Plot first N steps.

function random_walk_demo()
  N = 1e4 % number of steps
  L = 1 % step size
  num_walks = 50;

  % Figure 1 is the walk itself
  figure; % open a fig. window
  hold on; % keep all plots same axis

  final_r = zeros(1, num_walks); % store the final distances walked

  for n = 1:num_walks
    [x,y] = randomwalk(L, N); % generate random walk
    RGB = rand (1,3); % random colour point
    plot(x,y, 'Color', RGB) % plotting it
    final_r(n) = sqrt(x(end)^2 + y(end)^2); % final displacement
  endfor

  box on;
  grid on;
  xlabel('x (steps)');
  ylabel('y (steps)');
  title(sprintf('Random Walks: %d walks, %d steps, step size = %d', num_walks, N, L));
  savedir = 'C:\Users\Marc\OneDrive\Desktop\BPhO Computational Physics Competition\Competition Solutions';

  if ~exist(savedir, 'dir')
    mkdir(savedir);
  endif

  print(gcf, fullfile(savedir, 'random_walks.png'), '-dpng', '-r300');

  % Figure 2 is RMS displacement vs N
  step_sizes = round(logspace(1, log10(N), 50)); % 50 points from 10 to N
  rms_vals = zeros(1, length(step_sizes));
  num_samples = 100; % average over this many walks per point

  for i = 1:length(step_sizes)
    n_steps = step_sizes(i);
    r_sq = zeros(1, num_samples);
    for k = 1:num_samples
      [x, y] = randomwalk(L, n_steps);
      r_sq(k) = x(end)^2 + y(end)^2;
    endfor
    rms_vals(i) = sqrt(mean(r_sq));
  endfor

  figure;
  loglog(step_sizes, rms_vals, 'b.', 'MarkerSize', 10);
  hold on;
  loglog(step_sizes, L*sqrt(step_sizes), 'r-', 'LineWidth', 2); % theoretical sqrt(N)
  grid on;
  box on;
  xlabel('Number of Steps N');
  ylabel('RMS Displacement');
  title('RMS Displacement vs N');
  legend('Simulation', 'Theoretical: L/surdN', 'Location', 'northwest');
  savedir = 'C:\Users\Marc\OneDrive\Desktop\BPhO Computational Physics Competition\Competition Solutions';

  if ~exist(savedir, 'dir')
    mkdir(savedir);
  endif

  print(gcf, fullfile(savedir, 'rms_displacement.png'), '-dpng', '-r300');

end % end of random_walk_demo function

% Generate a random walk starting from (0,0)
function [x,y] = randomwalk(L, N)
  x = zeros(1, N+1); % preallocate for speed
  y = zeros(1, N+1);

  for n = 1:N
    theta = 2 * pi * rand;
    x(n+1) = x(n) + L * cos(theta);
    y(n+1) = y(n) + L * sin(theta);
  endfor

end % end of randomwalk
