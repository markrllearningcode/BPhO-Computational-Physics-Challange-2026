function task7_particle_in_box()

  % Task 7: Particle in a one-dimensional infinte potential well

  % Plots:
  % 1. Energy against quantum number n
  % 2. Probability density |psi_n(x)|^2 against position x

  % Model:
  % V(x) = 0 for 0 < x < a
  % V(x) = infinity outside of the box

  % psi_n(x) = sqrt(2/a) sin(n*pi*x/a)
  % E_n = n^2*pi^2*hbar^2 / (2*m*a^2)

  close all;
  clc;

  savedir = 'C:/Users/Marc/OneDrive/Desktop/BPhO Computational Physics Competition/Competition Solutions';

  if ~exist(savedir, 'dir')
    mkdir(savedir);
  endif

  % Constants
  h = 6.62607015e-34; % Planck constant / J s
  hbar = h / (2*pi); % Reduced Planck constant / J s
  m_e = 9.1093837015e-31; % Electron mass / kg
  e = 1.602176634e-19; % Elementary charge / C

  % Physical model
  particle_mass = m_e; % Electron in the box
  box_width_A = 0.529; % Box width / angstrom
  box_width = box_width_A * 1e-10; % Convert angstrom to metres

  n_energy_max = 3; % Energy levels
  n_density = [1 2 3]; % Probability densities shown
  number_of_points = 1500;

  % Position array inside the box
  u = linspace(0, 1, number_of_points);
  x_A = box_width_A .* u; % Position in angstrom
  x = x_A .* 1e-10;

  % Energy calculation
  n_values = 1:n_energy_max

  energy_J = (n_values.^2 * pi^2 * hbar^2) ./ (2 * particle_mass * box_width^2);

  energy_eV = energy_J / e;

  % Probability density calculation
  probability_density = zeros(length(n_density), length(x_A));
  normalisation_check = zeros(1, length(n_density));
  expected_x = zeros(1, length(n_density));

  for k = 1:length(n_density)
    n = n_density(k);

    % Probability density in inverse angstroms
    probability_density(k, :) = (2 / box_width_A) .* sin(n * pi .* u).^2;

    normalisation_check(k) = trapz(x_A, probability_density(k, :));

    expected_x(k) = trapz(x_A, x_A .* probability_density(k, :));
  endfor

  % Figure
  fig = figure('Name', 'Task 7 - Particle in a Box', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [60 70 1150 650]);

  % Panel 1: Energy against quantum number
  subplot(1, 2, 1);

  plot(n_values, energy_eV, 'o-', 'LineWidth', 2, 'MarkerSize', 7, 'MarkerFaceColor', [0.15 0.45 0.90], 'Color', [0.15 0.45 0.90]);

  hold on;

  % Add stems from the horizontal axis to each energy levels
  for k = 1:length(n_values)
    plot([n_values(k) n_values(k)], [0 energy_eV(k)], ':', 'Color', [0.65 0.65 0.65], 'HandleVisibility', 'off');
  endfor

  xlabel('Quantum number, n', 'FontSize', 12);
  ylabel('Energy, E_n / eV', 'FontSize', 12);

  title({'Energy Levels of an Electron in an Infinite Well', sprintf('Box width a = %.2f angstrom', box_width_A)}, 'FontSize', 13, 'FontWeight', 'bold');

  grid on;
  box on;
  xlim([0.5 n_energy_max + 0.5]);
  ylim([0 1.08 * max(energy_eV)]);
  set(gca, 'XTick', n_values, 'FontSize', 10, 'LineWidth', 1);

  energy_formula = sprintf(['E_n = n^2 pi^2 hbar^2 / (2ma^2)\n', 'E_1 = %.3f eV\n', 'Therefore E_n = n^2 E_1'], energy_eV(1));

  text(1.0, 0.72  * max(energy_eV), energy_formula, 'FontSize', 9, 'BackgroundColor', [1.00 1.00 0.86], 'EdgeColor', [0.70 0.60 0.20]);

  % Panel 2: Probability densities
  subplot(1, 2, 2);

  hold on;

  density_colours = [0.10 0.35 0.90; 0.10 0.65 0.25; 0.90 0.20 0.15];

  density_handles = zeros(1, length(n_density));

  for k = 1:length(n_density)
    density_handles(k) = plot(x_A, probability_density(k,:), 'Color', density_colours(k,:), 'LineWidth', 2);
  endfor

  % Classical uniform probability density for comparison.
  classical_density = ones(size(x_A)) / box_width_A;

  plot(x_A, classical_density, 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');

  text(0.03, 1.04 / box_width_A, 'Classical uniform density = 1/a', 'FontSize', 8, 'Color', [0.20 0.20 0.20]);

  xlabel('Position, x / angstrom', 'FontSize', 12);
  ylabel('Probability density, |\psi_n(x)|^2 / angstrom^{-1}', 'FontSize', 12);

  title({'Probability Densities in the Box', '\psi_n(x) = sqrt(2/a) sin(n\pi x/a)'}, 'FontSize', 13, 'FontWeight', 'bold');

  legend_labels = arrayfun( @(n) sprintf('n = %d, E_n = %.3f eV', n, energy_eV(n)), n_density, 'UniformOutput', false);

  legend(density_handles, legend_labels, 'Location', 'northeast', 'FontSize', 9);

  grid on;
  box on;
  xlim([0 box_width_A]);
  ylim([0 1.12 * max(probability_density(:))]);
  set(gca, 'FontSize', 10, 'LineWidth', 1);

  % Boundary-condition markers.
  current_ylim = ylim();

  plot([0 0], current_ylim, 'k-', 'LineWidth', 1.5, 'HandleVisibility', 'off');

  plot([box_width_A box_width_A], current_ylim, 'k-', 'LineWidth', 1.5, 'HandleVisibility', 'off');

  text(0.012, 0.92 * max(probability_density(:)), '\psi(0) = 0', 'FontSize', 9);

  text(box_width_A - 0.11, 0.92 * max(probability_density(:)), '\psi(a) = 0', 'FontSize', 9);

  % Command-window output
  fprintf('\nTASK 7: PARTICLE IN A ONE-DIMENSIONAL BOX\n');
  fprintf('------------------------------------------------------------\n');
  fprintf('Particle: electron\n');
  fprintf('Box width, a = %.3e m = %.3f angstrom\n\n', box_width, box_width_A);

  fprintf('Quantum number      Energy / J          Energy / eV\n');

  for k = 1:length(n_values)
    fprintf('%7d          %12.6e       %10.5f\n', n_values(k), energy_J(k), energy_eV(k));
  endfor

  fprintf('\nProbability-density checks:\n');
  fprintf('n      integral |psi|^2 dx      <x>/angstrom\n');

  for k = 1:length(n_density)
    fprintf('%d          %.8f              %.6f\n', n_density(k), normalisation_check(k), expected_x(k));
  endfor

  fprintf('\nFor every stationary state, <x> = a/2 = %.6f angstrom.\n', box_width_A / 2);

  % CSV
  energy_filename = fullfile(savedir, 'particle_in_box_energies.csv');
  fid = fopen(energy_filename, 'w');

  if fid == -1
    error('Could not open energy CSV file for writing: %s', energy_filename);
  endif

  fprintf(fid, 'quantum_number,energy_J,energy_eV\n');

  for k = 1:length(n_values)
    fprintf(fid, '%d,%.10e,%.10f\n', n_values(k), energy_J(k), energy_eV(k));
  endfor

  fclose(fid);


  density_filename = fullfile(savedir, 'particle_in_box_probability_densities.csv');
  fid = fopen(density_filename, 'w');

  if fid == -1
    error('Could not open density CSV file for writing: %s', density_filename);
  endif

  fprintf(fid, 'x_m,x_angstrom');

  for k = 1:length(n_density)
    fprintf(fid, ',density_n%d_per_angstrom', n_density(k));
  endfor

  fprintf(fid, '\n');

  for point = 1:length(x)
    fprintf(fid, '%.10e,%.10f', x(point), x_A(point));

    for k = 1:length(n_density)
      fprintf(fid, ',%.10e', probability_density(k, point));
    endfor

    fprintf(fid, '\n');
  endfor

  fclose(fid);

  % ---------------------------- Export -----------------------------
  set(fig, 'PaperPositionMode', 'auto');
  drawnow();
  print(fig, fullfile(savedir, 'particle_in_box_main.png'), '-dpng', '-r300');

  fprintf('\nSaved outputs:\n');
  fprintf('  particle_in_box_main.png\n');
  fprintf('  particle_in_box_energies.csv\n');
  fprintf('  particle_in_box_probability_densities.csv\n\n');
endfunction
