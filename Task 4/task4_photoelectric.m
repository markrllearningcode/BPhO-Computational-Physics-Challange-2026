function task4_photoelectric()
% Task 4: Photoelectric Effect
% Plots photoelectron stopping voltage against incident frequency and wavelength for several metals, then adds an interactive point explorer
% Einstein's photoelectric equation:
% K_max = h*f - phi
% e*V_s = K_max
% V_s = (h/e)*f -phi_eV
% The tabulated work functions below are representative values
% Real work functions vary slightly with surface condition, crystal face and oxidation

close all;
clc;

savedir = 'C:\Users\Marc\OneDrive\Desktop\BPhO Computational Physics Competition\Competition Solutions';

if ~exist(savedir, 'dir')
  mkdir(savedir);
endif

% Physical constraints
h = 6.62607012e-34; % Planck constant (J s)
e = 1.602176634e-19; % Elementary charge (C)
c = 2.99792458e8; % Speed of light in vacuum (m s^-1)

% Representative work funciotns in electronvolts
metals = {'Sodium', 'Calcium', 'Aluminium', 'Zinc', 'Copper', 'Gold'};
symbols = {'Na', 'Ca', 'Al', 'Zn', 'Cu', 'Au'};
phi_eV = [2.36, 2.90, 4.08, 4.31, 4.70, 5.10];
metal_colors = lines(length(metals));

% Frequencty and wavelength ranges
frequency = linspace(2.5e14, 2.6e15, 1800); % Hz
lambda_nm = linspace(100, 900, 1800); % nm
lambda_m = lambda_nm * 1e-9;

% Useful visible-spectrum boundaries
f_red = c / (700e-9);
f_violet = c / (380e-9);

% Fig 1: Stopping voltage against frequency
fig1 = figure('Name', 'Task 4 - Photoelectric Effect: Frequency', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [60 90 920 650]);
ax1 = axes('Parent', fig1, 'Position', [0.09 0.19 0.86 0.73]);
hold(ax1, 'on');

% Determine a sensible y-axis limit before adding the visible region patch
maximum_voltage = max((h/e) * frequency(end) - min(phi_eV));
y_limit = 1.08 * maximum_voltage;

% Shade the visible frequency interval
patch(ax1, [f_red f_violet f_violet f_red] / 1e15, [0 0 y_limit y_limit], [0.91 0.94 1.00], 'EdgeColor', 'none', 'FaceAlpha', 0.45, 'HandleVisibility', 'off');
text(ax1, mean([f_red f_violet]) / 1e15, 0.96*y_limit, 'Visible light', 'HorizontalAlignment', 'center', 'Color', [0.35 0.42 0.68], 'FontSize', 9);
h_lines = zeros(1, length(metals));
for i= 1:length(metals)
  V_stop = stopping_voltage_frequency(frequency, phi_eV(i), h, e);
  V_stop(frequency < cutoff_frequency(phi_eV(i), h, e)) = NaN;

  h_lines(i) = plot(ax1, frequency / 1e15, V_stop, 'Color', metal_colors(i,:), 'LineWidth', 1.9);

  % Mark the threshold frequency, where the line reached zero
  f_0 = cutoff_frequency(phi_eV(i), h, e);
  plot(ax1, f_0 / 1e15, 0, 'o', 'Color', metal_colors(i,:), 'MarkerFaceColor', metal_colors(i,:), 'MarkerSize', 5, 'HandleVisibility', 'off');
endfor

% Axes, labels and title
xlabel(ax1, 'Incident frequency, f (10^{15} Hz)', 'FontSize', 12);
ylabel(ax1, 'Stopping voltage, V_s (V)', 'FontSize', 12);
title(ax1, 'Photoelectron Stopping Voltage vs Incident Frequency', 'FontSize', 14, 'FontWeight', 'bold');
grid(ax1, 'on');
box(ax1, 'on');
xlim(ax1, [frequency(1) frequency(end)] /1e15);
ylim(ax1, [0 y_limit]);

legend_labels = cell(1, length(metals));
for i = 1:length(metals)
  legend_labels{i} = sprintf('%s (%s), \\phi = %.2f eV', metals{i}, symbols{i}, phi_eV(i));
endfor
legend(ax1, h_lines, legend_labels, 'Location', 'northwest', 'FontSize', 9);

% Equation annotation
equation_text = sprintf(['Einstein equation:\n', 'V_s = (h/e)f - \\phi\n', 'gradient = h/e = %.4e V s'], h/e);
text(ax1, 2.53, 0.82*y_limit, equation_text, 'HorizontalAlignment', 'right', 'FontSize', 9, 'BackgroundColor', [1.00 0.98 0.86], 'EdgeColor', [0.80 0.72 0.36], 'Margin', 7);

% Interactive controls
  uicontrol('Parent', fig1, 'Style', 'text', 'Units', 'normalized', 'Position', [0.07 0.105 0.13 0.035], ...
            'String', 'Selected metal:', 'BackgroundColor', [1 1 1], 'HorizontalAlignment', 'left');

  metal_menu = uicontrol('Parent', fig1, 'Style', 'popupmenu', 'Units', 'normalized', 'Position', [0.20 0.105 0.19 0.045], 'String', metals, 'Value', 1, 'Callback', @updatePoint);

  uicontrol('Parent', fig1, 'Style', 'text', 'Units', 'normalized', 'Position', [0.42 0.105 0.15 0.035], 'String', 'Incident frequency:', 'BackgroundColor', [1 1 1], 'HorizontalAlignment', 'left');

  freq_slider = uicontrol('Parent', fig1, 'Style', 'slider', 'Units', 'normalized', 'Position', [0.57 0.11 0.26 0.035], 'Min', frequency(1)/1e15, 'Max', frequency(end)/1e15, 'Value', 8.0e14/1e15, 'Callback', @updatePoint);

  point_label = uicontrol('Parent', fig1, 'Style', 'text', 'Units', 'normalized', 'Position', [0.07 0.025 0.86 0.06], 'String', '', 'BackgroundColor', [0.96 0.97 0.99], 'ForegroundColor', [0.12 0.15 0.22], 'FontSize', 10, 'HorizontalAlignment', 'center');

  % Initial interactive marker
  initial_f = get(freq_slider, 'Value') * 1e15;
  initial_V = max((h/e)*initial_f - phi_eV(1), 0);
  h_point = plot(ax1, initial_f/1e15, initial_V, 'ko', 'MarkerSize', 9, 'LineWidth', 2, 'MarkerFaceColor', [1 1 1], 'HandleVisibility', 'off');

  updatePoint([], []);
  drawnow();
  print(fig1, fullfile(savedir, 'photoelectric_stopping_voltage_frequency.png'), '-dpng', '-r300');

  % Fig 2: Stopping Voltage vs Wavelength
  fig2 = figure('Name', 'Task 4 - Photoelectric Effect: Wavelength', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [1010 90 850 620]);
  ax2 = axes('Parent', fig2, 'Position', [0.10 0.12 0.86 0.80]);
  hold(ax2, 'on');

  % Shade the visible-wavelength interval
  patch(ax2, [380 700 700 380], [0 0 y_limit y_limit], [0.91 0.94 1.00], 'EdgeColor', 'none', 'FaceAlpha', 0.45, 'HandleVisibility', 'off');
  text(ax2, 540, 0.96*y_limit, 'Visible light', 'HorizontalAlignment', 'center', 'Color', [0.35 0.42 0.68], 'FontSize', 9);

  h_wave_lines = zeros(1, length(metals));
  for i = 1:length(metals)
    V_stop_lambda = stopping_voltage_wavelength(lambda_m, phi_eV(i), h, c, e);
    lambda_0_nm = cutoff_wavelength(phi_eV(i), h, c, e) * 1e9;
    V_stop_lambda(lambda_nm > lambda_0_nm) = NaN;

    h_wave_lines(i) = plot(ax2, lambda_nm, V_stop_lambda, 'Color', metal_colors(i,:), 'LineWidth', 1.9);
    plot(ax2, lambda_0_nm, 0, 'o', 'Color', metal_colors(i,:), 'MarkerFaceColor', metal_colors(i,:), 'MarkerSize', 5, 'HandleVisibility', 'off');
  endfor

  xlabel(ax2, 'Incident wavelength in vacuum, \\lambda (nm)', 'FontSize', 12);
  ylabel(ax2, 'Stopping voltage, V_s (V)', 'FontSize', 12);
  title(ax2, 'Photoelectron Stopping Voltage vs Incident Wavelength', 'FontSize', 14, 'FontWeight', 'bold');
  grid(ax2, 'on');
  box(ax2, 'on');
  xlim(ax2, [100 900]);
  ylim(ax2, [0 y_limit]);
  legend(ax2, h_wave_lines, legend_labels, 'Location', 'northeast', 'FontSize', 9);

  text(ax2, 875, 0.78*y_limit, sprintf('V_s = hc/(e\\lambda) - \\phi\nNo emission when \\lambda > \\lambda_0'), 'HorizontalAlignment', 'right', 'FontSize', 9, 'BackgroundColor', [1.00 0.98 0.86], 'EdgeColor', [0.80 0.72 0.36], 'Margin', 7);

  drawnow();
  print(fig2, fullfile(savedir, 'photoelectric_stopping_voltage_wavelength.png'), '-dpng', '-r300');

  % Print and Export Threshold Data
  fprintf('\nTASK 4: PHOTOELECTRIC THRESHOLD DATA\n');
  fprintf('--------------------------------------------------------------\n');
  fprintf('%-12s %-8s %-12s %-16s %-16s\n', ...
          'Metal', 'phi/eV', 'f_0/Hz', 'lambda_0/nm', 'h estimate/J s');

  output_data = zeros(length(metals), 4);
  for i = 1:length(metals)
    f_0 = cutoff_frequency(phi_eV(i), h, e);
    lambda_0_nm = cutoff_wavelength(phi_eV(i), h, c, e) * 1e9;

    % Recover h using a scaled frequency axis to avooid numerical warnings
    fit_mask = frequency >= 1.05*f_0;

    frequency_fit_scaled = frequency(fit_mask) /1e15;
    voltage_fit = stopping_voltage_frequency(frequency(fit_mask), phi_eV(i), h, e);

    fit_coefficients = polyfit(frequency_fit_scaled, voltage_fit, 1);

    % polyfit gradient is now measured per 10^15 Hz
    gradient_V_per_Hz = fit_coefficients(1) / 1e15;
    h_estimate = gradient_V_per_Hz * e;

    fprintf('%-12s %-8.2f %-12.4e %-16.2f %-16.6e\n', ...
            metals{i}, phi_eV(i), f_0, lambda_0_nm, h_estimate);

    output_data(i,:) = [phi_eV(i), f_0, lambda_0_nm, h_estimate];
  endfor

  fid = fopen(fullfile(savedir, 'photoelectric_threshold_data.csv'), 'w');
  fprintf(fid, 'Metal,Symbol,Work function (eV),Cutoff frequency (Hz),Cutoff wavelength (nm),Estimated h (J s)\n');
  for i = 1:length(metals)
    fprintf(fid, '%s,%s,%.3f,%.8e,%.4f,%.8e\n', metals{i}, symbols{i}, output_data(i,1), output_data(i,2), output_data(i,3), output_data(i,4));
  endfor

  fclose(fid);

  fprintf('\nSaved outputs:\n');
  fprintf('  photoelectric_stopping_voltage_frequency.png\n');
  fprintf('  photoelectric_stopping_voltage_wavelength.png\n');
  fprintf('  photoelectric_threshold_data.csv\n\n');

  % Nested Callback for th interactive frequency plot
  function updatePoint(src, event)
    selected_index = get(metal_menu, 'Value');
    f_new = get(freq_slider, 'Value') * 1e15;
    lambda_new_nm = (c / f_new) * 1e9;
    photon_energy_eV = (h*f_new) / e;
    raw_voltage = photon_energy_eV - phi_eV(selected_index);
    f_0 = cutoff_frequency(phi_eV(selected_index), h, e);

    % Highlight the selected metal's curve
    for j = 1:length(h_lines)
      if j == selected_index
        set(h_lines(j), 'LineWidth', 3.2);
      else
        set(h_lines(j), 'LineWidth', 1.6);
      endif
    endfor

    if raw_voltage > 0
      V_new = raw_voltage;
      status_text = 'PHOTOELECTRONS EMITTED';
      status_color = [0.05 0.48 0.25];
    else
      V_new = 0;
      status_text = 'BELOW THRESHOLD: NO EMISSION';
      status_color = [0.72 0.16 0.12];
    endif

    set(h_point, 'XData', f_new/1e15, 'YData', V_new, 'MarkerEdgeColor', metal_colors(selected_index,:));
    set(point_label, 'ForegroundColor', status_color, 'String', sprintf(['%s | %s: \\phi = %.2f eV | ', 'f = %.3e Hz | \\lambda = %.1f nm | ', 'hf = %.3f eV | V_s = %.3f V | f_0 = %.3e Hz'], status_text, metals{selected_index}, phi_eV(selected_index), f_new, lambda_new_nm, photon_energy_eV, V_new, f_0));
    drawnow();
  endfunction
endfunction

% Stopping voltage as a function of frequency
% phi_eV is supplied in eV, so it is numericaly equal to phi/e in volts
function V_stop = stopping_voltage_frequency(frequency, phi_eV, h, e);
  V_stop = (h/e) .* frequency - phi_eV;
  V_stop = max(V_stop, 0);
endfunction

% Stopping voltage as a function of in-vacuum wavelength
function V_stop = stopping_voltage_wavelength(lambda_m, phi_eV, h, c, e)
  V_stop = (h*c) ./ (e .* lambda_m) - phi_eV;
  V_stop = max(V_stop, 0);
endfunction

% Threshold frequency f_0 = phi/h, converting phi from eV to joules
function f_0 = cutoff_frequency(phi_eV, h, e)
  f_0 = (phi_eV * e) / h;
endfunction

% Threshold wavelength lambda_0 = hc/phi
function lambda_0 = cutoff_wavelength(phi_eV, h, c, e)
  lambda_0 = (h*c) / (phi_eV * e);
endfunction
