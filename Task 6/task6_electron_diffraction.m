function task6_electron_diffraction()

  % TASK 6: Electron diffraction from graphite, models electron-diffraction rings on a spherical phosphor screen for accelerating voltages from 1 kV to 5 kV.
  % Definitions:
  %   theta = Bragg angle
  %   phi   = total scattering angle = 2*theta
  %   x     = ring radius on the screen
  % Physics:
  %   lambda = h/sqrt(2*m_e*e*V)
  %   2*d*sin(theta) = n*lambda
  %   phi = 2*theta
  %   x = r*sin(phi)
  % Verification graph:
  %   1/sqrt(V) against sin(phi/2) = sin(theta)

  close all;
  clc;

  savedir = 'C:/Users/Marc/OneDrive/Desktop/BPhO Computational Physics Competition/Competition Solutions';

  if ~exist(savedir, 'dir')
    mkdir(savedir);
  endif

  % Constants
  h = 6.62607015e-34;       % Planck constant / J s
  m_e = 9.1093837015e-31;  % Electron mass / kg
  e = 1.602176634e-19;     % Elementary charge / C
  c = 2.99792458e8;        % Speed of light / m s^-1

  screen_radius = 65e-3;   % Spherical phosphor-screen radius / m
  d_nm = [0.123, 0.213];   % Graphite layer spacings / nm
  d = d_nm * 1e-9;         % Convert to metres
  d_names = {'d = 0.123 nm', 'd = 0.213 nm'};

  orders = 1:3;
  V_kV = linspace(1, 5, 41);
  V = V_kV * 1e3;

  % Non-relativistic de Broglie wavelength.
  lambda = h ./ sqrt(2 * m_e * e .* V);

  % Optional relativistic comparison for the command-window output.
  lambda_rel = h ./ sqrt(2 * m_e * e .* V .* (1 + e .* V ./ (2 * m_e * c^2)));

  % Arrays: voltage index, spacing index, diffraction order.
  theta = NaN(length(V), length(d), length(orders));
  phi = NaN(size(theta));
  ring_radius = NaN(size(theta));

  for j = 1:length(d)
    for q = 1:length(orders)
      n = orders(q);
      bragg_argument = n .* lambda ./ (2 * d(j));
      valid = bragg_argument <= 1;

      theta(valid, j, q) = asin(bragg_argument(valid));
      phi(valid, j, q) = 2 .* theta(valid, j, q);

      ring_radius(valid, j, q) = screen_radius .* sin(phi(valid, j, q));
    endfor
  endfor

  % FIGURE 1: SIMULATED PHOSPHOR SCREENS

  display_voltages_kV = 1:5;

  fig1 = figure('Name', 'Task 6 - Simulated Electron Diffraction Rings', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [35 70 1250 720]);

  for panel = 1:5
    subplot(2, 3, panel);

    V_now = display_voltages_kV(panel) * 1e3;
    lambda_now = h / sqrt(2 * m_e * e * V_now);

    [screen_rgb, ring_table] = make_diffraction_screen(V_now, lambda_now, d, d_nm, orders, screen_radius);

    image(linspace(-65, 65, size(screen_rgb, 2)), linspace(-65, 65, size(screen_rgb, 1)), screen_rgb);

    axis image;
    axis xy;
    xlim([-67 67]);
    ylim([-67 67]);

    set(gca, 'XTick', [-60 -30 0 30 60], 'YTick', [-60 -30 0 30 60], 'FontSize', 8);

    xlabel('Screen position / mm');
    ylabel('Screen position / mm');

    title(sprintf('V = %.0f kV,  \\lambda = %.3f nm', V_now / 1e3, lambda_now * 1e9), 'FontSize', 10, 'FontWeight', 'bold');
  endfor

  % Sixth panel: compact explanation that stays inside its subplot.
  subplot(2, 3, 6);
  axis([0 1 0 1]);
  axis off;

  text(0.03, 0.93, 'Electron diffraction model', 'FontSize', 14, 'FontWeight', 'bold');

  equation_text = sprintf(['\\lambda = h / sqrt(2m_e eV)\n\n', '2d sin(\\theta) = n\\lambda\n\n', '\\phi = 2\\theta\n\n', 'x = r sin(\\phi)\n\n', 'r = 65 mm\n', 'd = 0.123 nm, 0.213 nm']);

  text(0.03, 0.80, equation_text, 'FontSize', 10, 'VerticalAlignment', 'top');

  explanation_text = sprintf(['As V increases:\n', '  momentum increases\n', '  wavelength decreases\n', '  diffraction angle decreases\n', '  ring radius decreases']);

  text(0.03, 0.29, explanation_text, 'FontSize', 9, 'VerticalAlignment', 'top', 'BackgroundColor', [1.00 1.00 0.86], 'EdgeColor', [0.70 0.60 0.20]);

  set(fig1, 'PaperPositionMode', 'auto');
  drawnow();
  print(fig1, fullfile(savedir, 'electron_diffraction_screens.png'), '-dpng', '-r250');

  % FIGURE 2: RING RADIUS AGAINST ACCELERATING VOLTAGE

  fig2 = figure('Name', 'Task 6 - Ring Radius vs Accelerating Voltage', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [90 90 1000 650]);

  hold on;

  spacing_colours = [0.10 0.65 0.20;
                     0.10 0.35 0.90];

  order_styles = {'-', '--', ':'};
  legend_handles = [];
  legend_labels = {};

  for j = 1:length(d)
    for q = 1:length(orders)
      handle = plot(V_kV, ring_radius(:, j, q) * 1e3, 'Color', spacing_colours(j, :), 'LineStyle', order_styles{q}, 'LineWidth', 2);

      legend_handles(end + 1) = handle;
      legend_labels{end + 1} = sprintf('%s, n = %d', d_names{j}, orders(q));
    endfor
  endfor

  xlabel('Accelerating voltage, V / kV', 'FontSize', 12);
  ylabel('Ring radius, x / mm', 'FontSize', 12);

  title({'Electron-Diffraction Ring Radius', 'Graphite layer spacings d = 0.123 nm and 0.213 nm'}, 'FontSize', 14, 'FontWeight', 'bold');

  grid on;
  box on;
  xlim([1 5]);
  ylim([0 65]);

  set(gca, 'FontSize', 10, 'LineWidth', 1);

  legend(legend_handles, legend_labels, 'Location', 'northeast', 'FontSize', 9);

  radius_note = sprintf(['Higher V  ->  smaller \\lambda\n', 'smaller \\theta  ->  smaller rings']);

  text(3.25, 54, radius_note, 'FontSize', 9, 'BackgroundColor', [1.00 1.00 0.86], 'EdgeColor', [0.70 0.60 0.20]);

  set(fig2, 'PaperPositionMode', 'auto');
  drawnow();
  print(fig2, fullfile(savedir, 'electron_diffraction_radius_vs_voltage.png'), '-dpng', '-r300');

  % FIGURE 3: STRAIGHT-LINE VERIFICATION

  % sin(theta) = n*h/[2*d*sqrt(2*m_e*e)] * 1/sqrt(V)
  %
  % Therefore:
  % 1/sqrt(V) = gradient * sin(theta)
  %
  % gradient = 2*d*sqrt(2*m_e*e)/(n*h)

  fig3 = figure('Name', 'Task 6 - Straight-Line Verification', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [140 120 950 620]);

  hold on;

  n_check = 1;
  fit_results = zeros(length(d), 3);

  max_x_value = 0;

  for j = 1:length(d)
    sin_half_phi = n_check .* lambda ./ (2 * d(j));
    inverse_root_V = 1 ./ sqrt(V);

    fit_coefficients = polyfit(sin_half_phi, inverse_root_V, 1);
    gradient = fit_coefficients(1);
    intercept = fit_coefficients(2);

    d_estimate = gradient * n_check * h / (2 * sqrt(2 * m_e * e));

    fit_results(j, :) = [gradient, intercept, d_estimate];

    plot(sin_half_phi, inverse_root_V, 'o', 'Color', spacing_colours(j, :), 'MarkerFaceColor', spacing_colours(j, :), 'MarkerSize', 5);

    x_fit = linspace(0, max(sin_half_phi) * 1.05, 150);

    plot(x_fit, polyval(fit_coefficients, x_fit), '-', 'Color', spacing_colours(j, :), 'LineWidth', 2, 'HandleVisibility', 'off');

    max_x_value = max(max_x_value, max(sin_half_phi));
  endfor

  xlabel('sin(\phi/2) = sin(\theta)', 'FontSize', 12);
  ylabel('1 / sqrt(V)  / V^{-1/2}', 'FontSize', 12);

  title({'Verification of the Electron-Diffraction Model', 'First-order diffraction, n = 1'}, 'FontSize', 14, 'FontWeight', 'bold');

  grid on;
  box on;
  set(gca, 'FontSize', 10, 'LineWidth', 1);

  xlim([0, 1.10 * max_x_value]);
  ylim([0, 1.08 * max(1 ./ sqrt(V))]);

  legend(d_names, 'Location', 'northwest', 'FontSize', 10);

  verification_text = sprintf(['1/sqrt(V) = k sin(\\phi/2)\n', 'd = n h k / [2 sqrt(2m_e e)]\n\n', 'Estimated d_1 = %.6f nm\n', 'Estimated d_2 = %.6f nm'], fit_results(1, 3) * 1e9, fit_results(2, 3) * 1e9);

  text(0.58 * max_x_value, 0.024, verification_text, 'FontSize', 9, 'BackgroundColor', [1.00 1.00 0.86], 'EdgeColor', [0.70 0.60 0.20]);

  set(fig3, 'PaperPositionMode', 'auto');
  drawnow();
  print(fig3, fullfile(savedir, 'electron_diffraction_linear_check.png'), '-dpng', '-r300');

  % COMMAND-WINDOW OUTPUT

  fprintf('\nTASK 6: ELECTRON DIFFRACTION\n');
  fprintf('---------------------------------------------------------------\n');
  fprintf('Voltage/kV   wavelength/nm   d/nm   order   ring radius/mm\n');

  output_voltages_kV = 1:5;

  for a = 1:length(output_voltages_kV)
    V_now = output_voltages_kV(a) * 1e3;
    lambda_now = h / sqrt(2 * m_e * e * V_now);

    for j = 1:length(d)
      for q = 1:length(orders)
        n = orders(q);
        argument = n * lambda_now / (2 * d(j));

        if argument <= 1
          theta_now = asin(argument);
          phi_now = 2 * theta_now;
          radius_now = screen_radius * sin(phi_now);

          fprintf('%7.1f      %10.5f     %5.3f     %d       %10.3f\n', V_now / 1e3, lambda_now * 1e9, d_nm(j), n, radius_now * 1e3);
        endif
      endfor
    endfor
  endfor

  fprintf('\nStraight-line estimates from first-order diffraction:\n');
  fprintf('Input d/nm    fitted gradient       estimated d/nm\n');

  for j = 1:length(d)
    fprintf('%8.3f      %12.6e        %10.6f\n', d_nm(j), fit_results(j, 1), fit_results(j, 3) * 1e9);
  endfor

  correction_percent = 100 * max(abs(lambda_rel - lambda) ./ lambda);

  fprintf('\nMaximum relativistic wavelength correction from 1-5 kV: %.4f %%\n', correction_percent);

  % CSV EXPORT

  filename = fullfile(savedir, 'electron_diffraction_data.csv');
  fid = fopen(filename, 'w');

  if fid == -1
    error('Could not open CSV file for writing: %s', filename);
  endif

  fprintf(fid, ['voltage_kV,wavelength_nm,spacing_nm,order,', 'bragg_angle_deg,scattering_angle_deg,ring_radius_mm\n']);

  for a = 1:length(V)
    for j = 1:length(d)
      for q = 1:length(orders)
        if !isnan(ring_radius(a, j, q))
          fprintf(fid, '%.6f,%.8f,%.6f,%d,%.8f,%.8f,%.8f\n', V_kV(a), lambda(a) * 1e9, d_nm(j), orders(q), theta(a, j, q) * 180 / pi, phi(a, j, q) * 180 / pi, ring_radius(a, j, q) * 1e3);
        endif
      endfor
    endfor
  endfor

  fclose(fid);

  fprintf('\nSaved outputs:\n');
  fprintf('  electron_diffraction_screens.png\n');
  fprintf('  electron_diffraction_radius_vs_voltage.png\n');
  fprintf('  electron_diffraction_linear_check.png\n');
  fprintf('  electron_diffraction_data.csv\n\n');
endfunction


function [rgb, ring_table] = make_diffraction_screen(V, lambda, d, d_nm, orders, screen_radius)

  % Creates a synthetic green phosphor screen.

  number_of_pixels = 420;
  screen_mm = screen_radius * 1e3;

  axis_mm = linspace(-screen_mm, screen_mm, number_of_pixels);
  [X, Y] = meshgrid(axis_mm, axis_mm);
  rho = sqrt(X.^2 + Y.^2);

  intensity = 0.018 * ones(size(rho));

  % Bright central transmitted beam.
  intensity += 1.25 * exp(-(rho / 2.2).^2);

  ring_table = [];
  ring_width_mm = 0.75;

  for j = 1:length(d)
    for q = 1:length(orders)
      n = orders(q);
      argument = n * lambda / (2 * d(j));

      if argument <= 1
        theta_now = asin(argument);
        phi_now = 2 * theta_now;
        radius_mm = screen_radius * sin(phi_now) * 1e3;

        amplitude = (1.0 - 0.14 * (n - 1)) * (1.0 - 0.17 * (j - 1));

        intensity += amplitude .* exp(-0.5 .* ((rho - radius_mm) ./ ring_width_mm).^2);

        ring_table(end + 1, :) = [d_nm(j), n, radius_mm];
      endif
    endfor
  endfor

  % Subtle deterministic texture.
  rand('seed', round(V));
  intensity += 0.025 .* rand(size(intensity));

  % Circular screen mask.
  mask = rho <= screen_mm;
  intensity = intensity .* mask;
  intensity = intensity ./ max(intensity(:));
  intensity = intensity .^ 0.62;

  rgb = zeros(number_of_pixels, number_of_pixels, 3);
  rgb(:, :, 1) = 0.02 .* intensity;
  rgb(:, :, 2) = 0.18 .* mask + 0.82 .* intensity;
  rgb(:, :, 3) = 0.035 .* intensity;

  outside = !mask;

  for channel = 1:3
    layer = rgb(:, :, channel);
    layer(outside) = 0.02;
    rgb(:, :, channel) = layer;
  endfor
endfunction
