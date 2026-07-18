function task3_radiation()
  % task 3 is the Planck Black Body Radiation and Einstein Heat Capacity
  % physical constraints
  h = 6.62e-34; % Planck constant (J.s)
  c = 3e8; % Speed of light(ms^-1)
  k_B = 1.381e-23; % Boltzmann constant (J/K)
  N_A = 6.022e23; % Avogadro's number

  % Wavelength range (nm -> m)
  lambda_nm = linspace(100, 3000, 3000);
  lambda = lambda_nm * 1e-9;

  % Temperatures for Planck plot
  temps = [3000, 4000, 5000, 6000];
  colors = lines(length(temps));

  % Einstein frequencies (Hz) for different materials
  % theta_E = h*nu_E/k_B (Einstein Temperature)
  materials = {'Gold', 'Copper', 'Iron', 'Diamond'};
  theta_E = [165, 343, 470, 1450]; % <- Einstein Temperatures
  mat_colors = [1 0.8 0; 0.7 0.3 0; 0.5 0.5 0.5; 0.2 0.8 1];

  savedir = 'C:\Users\Marc\OneDrive\Desktop\BPhO Computational Physics Competition\Competition Solutions';

  if ~exist(savedir, 'dir')
    mkdir(savedir);
  endif

  % Fig 1: Planck Spectrum
  fig1 = figure('Name', 'Planck Black Body Spectrum', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [50 120 900 600]);
  hold on;

  h_lines = zeros(1, length(temps));
  for i = 1:length(temps)
    T = temps(i);
    B = planck(lambda, T, h, c, k_B);
    h_lines(i) = plot(lambda_nm, B * 1e-9, 'Color', colors(i,:), 'LineWidth', 2);
  endfor

  % Wien's law peak markers
  for i = 1:length(temps)
    T = temps(i);
    lambda_peak = 2.898e-3 / T; % Wien's displacement law (m)
    lambda_peak_nm = lambda_peak * 1e9;
    B_peak = planck(lambda_peak, T, h, c, k_B);
    plot(lambda_peak_nm, B_peak * 1e-9, 'v', 'Color', colors(i,:), 'MarkerSize', 8, 'MarkerFaceColor', colors(i,:), 'HandleVisibility', 'off');
  endfor

  % Shade visible spectrum (380-700nm)
  vis_x = [380 700 700 380];
  vis_y = [0 0 1e6 1e6];
  fill(vis_x, vis_y, [0.9 0.9 1.0], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
  text(540, 0.5, 'Visible', 'FontSize', 8, 'HorizontalAlignment', 'center', 'Color', [0.4 0.4 0.8]);

  legend_strs = arrayfun(@(T) sprintf('T = %dk', T), temps, 'UniformOutput', false);
  legend(h_lines, legend_strs, 'Location', 'northeast', 'FontSize', 10);

  xlabel('Wavelength /lambda (nm)', 'FontSize', 12);
  ylabel('Spectral Irradiance (W/m^2/nm)', 'FontSize', 12);
  title('Planck Black Body Radiation Spectrum', 'FontSize', 14);
  grid on;
  box on;
  ylim([0 1.1 * max(planck(lambda, max(temps), h, c, k_B) * 1e-9)]);

  % Add Wien's law annotation
  text(2200, 8e4, sprintf('Wiens Law:\nlambda-peak = b/T\nb = 2.898e-3 m.K'), 'FontSize', 9, 'BackgroundColor', [1 1 0.8], 'EdgeColor', [0.7 0.7 0]);

  % Slider to add custom temperature
  uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.12 0.01 0.25 0.04], 'String', 'Custom T (K):', 'BackgroundColor', [1 1 1]);
  temp_slider = uicontrol('Style', 'slider', 'Units', 'normalized', 'Position', [0.38 0.01 0.35 0.04], 'Min', 1000, 'Max', 10000, 'Value', 5778, 'Callback', @updatePlanck);
  temp_label = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.74 0.01 0.15 0.04], 'String', 'T = 5778K', 'BackgroundColor', [1 1 1]);

  % Plot line for slider temperature
  h_custom = plot(lambda_nm, planck(lambda, 5778, h, c, k_B)*1e-9, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
  drawnow();
  print(fig1, fullfile(savedir, 'planck_spectrum.png'), '-dpng', '-r300');

  % Fig 2 -> Einstein Heat Capacity
  fig2 = figure('Name', 'Einstein Heat Capacity', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [820 200 750 550]);
  hold on;

  T_range = linspace(1, 1200, 1000);
  R = N_A * k_B; % gas constant
  h_mat = zeros(1, length(materials));
  for i = 1:length(materials)
    Cv = einstein_Cv(T_range, theta_E(i), R);
    h_mat(i) = plot(T_range, Cv, 'Color', mat_colors(i,:), 'LineWidth', 2);
  endfor

  % Dolung-Petit limit LIne
  plot([0 1200], [3*R 3*R], 'k--', 'LineWidth', 1.55);
  text(1100, 3*R + 0.3, 'Dulong-Petit: 3R', 'FontSize', 9, 'HorizontalAlignment', 'right');

  legend(h_mat, materials, 'Location', 'southeast', 'FontSize', 10);
  xlabel('Temperature T (K)', 'FontSize', 12);
  ylabel('Molar Heat Capacity C_V (J/mol/K)', 'FontSize', 14);
  grid on;
  box on;

  % Add Einstein temperature markers on x-axis
  for i = 1:length(materials)
    plot([theta_E(i) theta_E(i)], [0 25], '--', 'Color', mat_colors(i,:), 'HandleVisibility', 'off');
    text(theta_E(i), 1.0, sprintf('\\theta_E\n(%s)', materials{i}), 'FontSize', 7, 'HorizontalAlignment', 'center', 'Color', mat_colors(i,:));
  endfor
  % Slider for custom Einstein temperature

  uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.12 0.01 0.3 0.04], 'String', 'Custom \theta_E (K):', 'BackgroundColor', [1 1 1]);
  theta_slider = uicontrol('Style', 'slider', 'Units', 'normalized', 'Position', [0.43 0.01 0.35 0.04], 'Min', 50, 'Max', 2000, 'Value', 500, 'Callback', @updateEinstein);
  theta_label = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.79 0.01 0.1 0.04], 'String', '\theta_E = 500K', 'BackgroundColor', [1 1 1]);

  h_custom_E = plot(T_range, einstein_Cv(T_range, 500, R), 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');

  drawnow();
  print(fig2, fullfile(savedir, 'einstein_heat_capacity.png'), '-dpng', '-r300');

  % Nested callback functions
  function updatePlanck(src, ~)
    T_new = round(get(src, 'Value'));
    set(temp_label, 'String', sprintf('T = %dK', T_new));
    set(h_custom, 'YData', planck(lambda, T_new, h, c, k_B) * 1e-9);
    drawnow();
  endfunction

  function updateEinstein(src, ~)
    theta_new = round(get(src, 'Value'));
    set(theta_label, 'String', sprintf('\\theta_E = %dK', theta_new));
    set(h_custom_E, 'YData', einstein_Cv(T_range, theta_new, R));
    drawnow();
  endfunction
endfunction

% Planck spectral radiance b(lambda, T) in W/m^2/m
function B = planck(lambda, T, h, c, k_B)
  B = (2 * h * c^2 ./ lambda.^5) ./ (exp((h*c) ./ (lambda * k_B * T)) - 1);
endfunction

% Einstein molar heat capacity
function Cv = einstein_Cv(T, theta_E, R)
  x = theta_E ./ T;
  Cv = 3 * R * x.^2 .* exp(x) ./ (exp(x) - 1).^2;
endfunction
