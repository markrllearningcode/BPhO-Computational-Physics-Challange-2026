function task9_compton_scattering()
  % Task 9: Compton scattering

  % Plots against photon scattering angle theta:
  % 1. Fractional wavelength shift, Delta_lambda/lambda
  % 2. Electron recoil speed, v/c
  % 3. Electron recoil angle, phi

  % Photon energires: 50, 100, 200, 500, and 1000keV

  close all;
  clc;

  savedir = 'C:/Users/Marc/OneDrive/Desktop/BPhO Computational Physics Competition/Competition Solutions';

  if ~exist(savedir, 'dir')
    mkdir(savedir);
  endif

  % Constants
  h = 6.62607015e-34; % Planck constant / J s
  c = 2.99792458e8; % Speed of light / m s^-1
  e = 1.602176634e-19; % elementary charge / C
  m_e = 9.1093837015e-31; % mass of electron / kg

  rest_energy_J = m_e * c^2;
  rest_energy_keV = rest_energy_J / e / 1e3;
  compton_wavelength = h / (m_e * c);

  % Model settings
  photon_energies_keV = [50 100 200 500 1000];
  theta_deg = linspace(0, 180, 721);
  theta_rad = theta_deg * pi / 180;

  number_of_energies = length(photon_energies_keV);
  colours = lines(number_of_energies);

  fractional_shift = zeros(number_of_energies, length(theta_deg));
  recoil_beta = zeros(size(fractional_shift));
  recoil_speed = zeros(size(fractional_shift));
  recoil_angle_deg = zeros(size(fractional_shift));
  scattered_energy_keV = zeros(size(fractional_shift));

  % Calculations
  for k = 1:number_of_energies
    E_keV = photon_energies_keV(k);
    alpha = E_keV / rest_energy_keV;

    fractional_shift(k,:) = alpha .* (1 - cos(theta_rad));

    scattered_energy_keV(k,:) = E_keV ./ (1 + alpha .* (1 - cos(theta_rad)));

    electron_kinetic_keV = E_keV - scattered_energy_keV(k,:);

    gamma = 1 + electron_kinetic_keV ./ rest_energy_keV;
    recoil_beta(k,:) = sqrt(max(0, 1 -1 ./ gamma.^2));
    recoil_speed(k,:) = recoil_beta(k,:) .* c;

    numerator = scattered_energy_keV(k,:) .* sin(theta_rad);

    denominator = E_keV - scattered_energy_keV(k,:) .* cos(theta_rad);

    recoil_angle_deg(k,:) = atan2(numerator, denominator) .* 180 / pi;

    % At theta = 0 there is no recoil, 90 degrees is the limiting angle
   recoil_angle_deg(k,1) = 90;
  endfor

  % Figure
  fig = figure('Name', 'Task 9 - Compton Scattering', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [45 55 1180 760]);

  legend_labels = arrayfun(@(E) sprintf('E= %d keV', E), photon_energies_keV, 'UniformOutput', false);

  % Panel 1: fractional wavelength shift
  subplot(2, 2, 1);
  hold on;
  handles_1 = zeros(1, number_of_energies);

  for k = 1:number_of_energies
    handles_1(k) = plot(theta_deg, fractional_shift(k,:), 'Color', colours(k,:), 'LineWidth', 2);
  endfor

  xlabel('Photon scattering angle, \theta / degrees', 'FontSize', 11);
  ylabel('Fractional shift, \Delta\lambda/\lambda', 'FontSize', 11);
  title('fractional Compton Wavelength Shift', 'FontSize', 13, 'FontWeight', 'bold');
  legend(handles_1, legend_labels, 'Location', 'northwest', 'FontSize', 8);
  xlim([0 180]);
  grid on;
  box on;
  set(gca, 'FontSize', 9, 'LineWidth', 1);

  % Panel 2: electron recoil speed
  subplot(2, 2, 2);
  hold on;
  handles_2 = zeros(1, number_of_energies);
  for k = 1:number_of_energies
    handles_2(k) = plot(theta_deg, recoil_beta(k,:), 'Color', colours(k,:), 'LineWidth', 2);
  endfor

  xlabel('Photon scattering angle, \theta / degrees', 'FontSize', 11);
  ylabel('Electron recoil speed, v/c', 'FontSize', 11);
  title('Relativistic Electron Recoil Speed', 'FontSize', 13, 'FontWeight', 'bold');
  legend(handles_2, legend_labels, 'Location', 'southeast', 'FontSize', 8);
  xlim([0 180]);
  ylim([0 1]);
  grid on;
  box on;
  set(gca, 'FontSize', 9, 'LineWidth', 1);

    % Panel 3: electron recoil angle
  subplot(2, 2, 3);
  hold on;
  handles_3 = zeros(1, number_of_energies);

  for k = 1:number_of_energies
    handles_3(k) = plot( theta_deg, recoil_angle_deg(k, :), 'Color', colours(k, :), 'LineWidth', 2);
  endfor

  xlabel('Photon scattering angle, \theta / degrees', 'FontSize', 11);
  ylabel('Electron recoil angle, \phi / degrees', 'FontSize', 11);
  title('Electron Recoil Direction', 'FontSize', 13, 'FontWeight', 'bold');
  legend(handles_3, legend_labels, 'Location', 'northeast', 'FontSize', 8);
  xlim([0 180]);
  ylim([0 90]);
  grid on;
  box on;
  set(gca, 'FontSize', 9, 'LineWidth', 1);

  % Panel 4: equations
  subplot(2, 2, 4);
  axis([0 1 0 1]);
  axis off;

  text(0.03, 0.94, 'Compton-scattering model', 'FontSize', 14, 'FontWeight', 'bold');

  equation_text = sprintf(['\\Delta\\lambda = h/(m_e c)(1 - cos\\theta)\n\n', 'E'' = E/[1 + E/(m_e c^2)(1 - cos\\theta)]\n\n', 'K_e = E - E''\n\n', '\\gamma = 1 + K_e/(m_e c^2)\n', 'v/c = sqrt(1 - 1/\\gamma^2)\n\n', 'tan\\phi = E''sin\\theta/(E - E''cos\\theta)']);

  text(0.03, 0.83, equation_text, 'FontSize', 10, 'VerticalAlignment', 'top');

  interpretation_text = sprintf(['Compton wavelength:\n', 'h/(m_e c) = %.5e m\n\n', 'Electron rest energy:\n', 'm_e c^2 = %.3f keV\n\n', 'Higher incident energy gives:\n', '  larger fractional shifts\n', '  faster recoil electrons\n', '  smaller recoil angles'], compton_wavelength, rest_energy_keV);

  text(0.03, 0.38, interpretation_text, 'FontSize', 9, 'VerticalAlignment', 'top', 'BackgroundColor', [1.00 1.00 0.86], 'EdgeColor', [0.70 0.60 0.20]);

  % Command-window output
  fprintf('\nTASK 9: COMPTON SCATTERING\n');
  fprintf('--------------------------------------------------------------\n');
  fprintf('Electron rest energy = %.6f keV\n', rest_energy_keV);
  fprintf('Compton wavelength   = %.6e m\n\n', compton_wavelength);

  sample_angles = [30 60 90 120 150 180];

  fprintf(['Energy/keV  theta/deg  Delta_lambda/lambda  ', 'v/c       phi/deg\n']);

  for k = 1:number_of_energies
    for a = 1:length(sample_angles)
      [~, index] = min(abs(theta_deg - sample_angles(a)));

      fprintf('%9.0f  %9.0f      %10.6f       %7.5f   %8.3f\n', photon_energies_keV(k), theta_deg(index), fractional_shift(k, index), recoil_beta(k, index), recoil_angle_deg(k, index));
    endfor
  endfor

  % CSV export
  csv_filename = fullfile(savedir, 'compton_scattering_data.csv');
  fid = fopen(csv_filename, 'w');

  if fid == -1
    error('Could not open CSV file for writing: %s', csv_filename);
  endif

  fprintf(fid, ['incident_energy_keV,theta_deg,fractional_shift,', ...
              'scattered_energy_keV,recoil_speed_m_per_s,', ...
              'recoil_speed_over_c,recoil_angle_deg\n']);

  for k = 1:number_of_energies
    for index = 1:length(theta_deg)
      fprintf(fid, '%.6f,%.6f,%.10e,%.10f,%.10e,%.10f,%.10f\n', ...
              photon_energies_keV(k), theta_deg(index), ...
              fractional_shift(k, index), scattered_energy_keV(k, index), ...
              recoil_speed(k, index), recoil_beta(k, index), ...
              recoil_angle_deg(k, index));
    endfor
  endfor

  fclose(fid);

  set(fig, 'PaperPositionMode', 'auto');
  drawnow();
  print(fig, fullfile(savedir, 'compton_scattering_main.png'), '-dpng', '-r300');

  fprintf('\nSaved outputs:\n');
  fprintf('  compton_scattering_main.png\n');
  fprintf('  compton_scattering_data.csv\n\n');
endfunction

