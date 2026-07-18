function task5_hydrogen_spectrum()
  % Task 5: Hydrogen emission spectrum and Bohr Model
  % Creates a graph of proton energy against wavelength for transitions in hydrogen (Z = 1), covering the Lyman, Balmer, Paschen, Brackett and Pfund series.
  % This program also exports a CSV data table

  close all;
  clc;

  % Constants
  h = 6.62607015e-34; % Planck constant / J s
  c = 2.99792458e8; % Speed of light / m s^-1
  e = 1.602176634e-19; % Elementary charge / C
  E_1 = 13.605693; % Magnitude of H ground-state energy / eV
  Z = 1; % Nuclear charge for hydrogen

  savedir = 'C:/Users/Marc/OneDrive/Desktop/BPhO Computational Physics Competition/Competition Solutions';

  if ~exist(savedir, 'dir')
    mkdir(savedir);
  endif

  series_names = {'Lyman', 'Balmer', 'Paschen', 'Brackett', 'Pfund'};
  series_colors = [ 1.00 0.00 1.00; 1.00 0.15 0.10; 0.10 0.30 1.00; 0.10 0.80 0.20; 0.10 0.10 0.10];

  n_max = 20; % Highest inital level included
  x_max = 8000; % Wavelength-axis maximum / nm
  y_max = 14.0; % Energy-axis maximum / eV

  % Figure
  fig = figure('Name', 'Task 5 - Hydrogen Emission Spectrum', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [70 60 1100 700]);
  ax = axes('Parent', fig, 'Position', [0.08 0.11 0.87 0.80]);
  hold(ax, 'on');

  % Shade the visible light region
  patch(ax, [380 750 750 380], [0 0 y_max y_max], [0.93 0.95 1.00], 'EdgeColor', 'none', 'HandleVisibility', 'off');

  text(ax, 565, 13.55, 'Visible light', 'HorizontalAlignment', 'center', 'Color', [0.35 0.35 0.75], 'FontSize', 9);

  legend_handles = zeros(1, 5);

  % Calculate and plot
  all_rows = cell(0, 7);

  for m = 1:5
    colour = series_colors(m, :);
    legend_handles(m) = plot(ax, NaN, NaN, '*', 'Color', colour, 'MarkerSize', 7, 'LineWidth', 1.2);

    for n = (m + 1):n_max
      photon_energy_eV = E_1 * Z^2 * (1 / m^2 - 1 / n^2);
      wavelength_nm = h * c / (photon_energy_eV * e) * 1e9;
      frequency_Hz = c / (wavelength_nm * 1e-9);

      if wavelength_nm <= x_max
        plot(ax, [wavelength_nm wavelength_nm], [0 photon_energy_eV], ':', 'Color', colour, 'LineWidth', 0.8, 'HandleVisibility', 'off');

        plot(ax, wavelength_nm, photon_energy_eV, '*', 'Color', colour, 'MarkerSize', 6, 'LineWidth', 1.0, 'HandleVisibility', 'off');
      endif

      region = electromagnetic_region(wavelength_nm);
      all_rows(end + 1, :) = {series_names{m}, m, n, wavelength_nm, frequency_Hz, photon_energy_eV, region};
    endfor

    % Series limit, corresponding to n -> infinity
    limit_energy_eV = E_1 * Z^2 / m^2;
    limit_wavelength_nm = h * c / (limit_energy_eV * e) * 1e9;

    if limit_wavelength_nm <= x_max
      plot(ax, [limit_wavelength_nm limit_wavelength_nm], [0 limit_energy_eV], '--', 'Color', colour, 'LineWidth', 1.2, 'HandleVisibility', 'off');
    endif
  endfor

  % Label the first four Balmer lines
  balmer_n = 3:6;
  balmer_labels = {'H\alpha', 'H\beta', 'H\gamma', 'H\delta'};

  % Separate horizontal and vertical offsets to avoid overlap
  x_offsets = [35, 45, 55, 65];
  y_offsets = [0.15, 0.35, 0.55, 0.75];

  for k = 1:length(balmer_n)
    n = balmer_n(k);

    energy_eV = E_1 * Z^2 * (1 / 2^2 - 1 / n^2);
    wavelength_nm = h * c / (energy_eV * e) * 1e9;

    text(ax, wavelength_nm + x_offsets(k), energy_eV + y_offsets(k), balmer_labels{k}, 'Color', series_colors(2,:), 'FontSize', 9, 'FontWeight', 'bold');
  endfor

  % Presentation
  xlim(ax, [0 x_max]);
  ylim(ax, [0 y_max]);
  grid(ax, 'on');
  box(ax, 'on');
  set(ax, 'FontSize', 10, 'LineWidth', 1, 'Layer', 'top');

  xlabel(ax, 'Wavelength, \lambda / nm', 'FontSize', 12);
  ylabel(ax, 'Photon energy, E_\gamma / eV', 'FontSize', 12);

  title(ax, {'Hydrogen Emission Spectrum and Bohr Model', 'Photon energy against emitted wavelength, Z = 1'}, 'FontSize', 14, 'FontWeight', 'bold');

  legend(ax, legend_handles, series_names, 'Location', 'northeast', 'FontSize', 10);

  formula_text = sprintf(['Bohr energy levels:\n', 'E_n = -13.6057 Z^2/n^2 eV\n\n', 'Photon energy:\n', 'E_gamma = 13.6057 Z^2(1/m^2 - 1/n^2)\n\n', 'Wavelength:\n', 'lambda = hc/E_gamma']);

  text(ax, 4700, 10.9, formula_text, 'FontSize', 9, 'BackgroundColor', [1.00 1.00 0.86], 'EdgeColor', [0.70 0.60 0.20]);

  % Command-window output
  fprintf('\nTASK 5: HYDROGEN EMISSION SPECTRUM\n');
  fprintf('--------------------------------------------------------------\n');
  fprintf('Series      limit lambda/nm     limit energy/eV\n');

  for m = 1:5
    limit_energy_eV = E_1 / m^2;
    limit_wavelength_nm = h * c / (limit_energy_eV * e) * 1e9;
    fprintf('%-10s  %12.2f        %10.4f\n', ...
            series_names{m}, limit_wavelength_nm, limit_energy_eV);
  endfor

  fprintf('\nSelected visible Balmer lines:\n');
  fprintf('Transition       wavelength/nm      photon energy/eV\n');

  for n = 3:6
    energy_eV = E_1 * (1 / 2^2 - 1 / n^2);
    wavelength_nm = h * c / (energy_eV * e) * 1e9;
    fprintf('n = %d -> 2       %10.2f             %8.4f\n', n, wavelength_nm, energy_eV);
  endfor

  % Export
  set(fig, 'PaperPositionMode', 'auto');
  drawnow();
  print(fig, fullfile(savedir, 'hydrogen_emission_spectrum.png'), '-dpng', '-r300');

  filename = fullfile(savedir, 'hydrogen_emission_data.csv');
  fid = fopen(filename, 'w');

  if fid == -1
    error('Could not open CSV file for writing: %s', filename);
  endif

  fprintf(fid, ['series,final_level_m,initial_level_n,', 'wavelength_nm,frequency_Hz,photon_energy_eV,region\n']);

  for row = 1:size(all_rows, 1)
    fprintf(fid, '%s,%d,%d,%.8f,%.8e,%.8f,%s\n', all_rows{row, 1}, all_rows{row, 2}, all_rows{row, 3}, all_rows{row, 4}, all_rows{row, 5}, all_rows{row, 6}, all_rows{row, 7});
  endfor

  fclose(fid);

  fprintf('\nSaved outputs:\n');
  fprintf('  hydrogen_emission_spectrum.png\n');
  fprintf('  hydrogen_emission_data.csv\n\n');
endfunction


function region = electromagnetic_region(wavelength_nm)
  if wavelength_nm < 380
    region = 'Ultraviolet';
  elseif wavelength_nm <= 750
    region = 'Visible';
  else
    region = 'Infrared';
  endif
endfunction
