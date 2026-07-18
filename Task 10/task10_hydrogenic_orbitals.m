function task10_hydrogenic_orbitals()

  % Task 10: Hydrogenic orbitals

  % Produces:
  % 1. Three 2d probability density slices
  % 2. A radial probability graph
  % 3. A semi-transparent coloured glass 3D plot
  % 4. A phase-coloured 3D isosurface

  close all;
  clc;

  savedir = 'C:/Users/Marc/OneDrive/Desktop/BPhO Computational Physics Competition/Competition Solutions';

  if ~exist(savedir, 'dir')
    mkdir(savedir);
  endif

  % User settings
  Z = 1; % Nuclear charge: H = 1
  A = 1; % Approximate nuclear mass number
  n = 3; % Principal quantum number
  l = 2; % 0 <= l <= n-1
  m = 0; % -l <= m <= l
  threshold = 0.15; % Hide normalised vaules below this

  grid_2D = 221;
  grid_3D = 65;
  number_of_slices = 13;

  % Validation
  if n < 1 || n != round(n)
    error('m must be a positive integer');
  endif

  if l < 0 || l > n-1 || l != round(l);
    error('l must be an integer from 0 to n-1');
  endif

  if abs(m) > l || m != round(m)
    error('m must be an integer from -l to +l');
  endif

  % Constants
  h = 6.62607015e-34;
  hbar = h / (2*pi);
  e = 1.602176634e-19;
  epsilon_0 = 8.8541878128e-12;
  m_e = 9.1093837015e-31;
  u = 1.66053906660e-27;

  nucleus_mass = A * u;
  reduced_mass = m_e * nucleus_mass / (m_e + nucleus_mass);

  a_0 = 4*pi*epsilon_0*hbar^2 / (m_e*e^2);
  a = (m_e/reduced_mass) * a_0 / Z;
  a_A = a * 1e10;

  energy_J = -(reduced_mass * e^4 * Z^2) / (8 * epsilon_0^2 * h^2 * n^2);
  energy_eV = energy_J / e;

  label = orbital_label(l);
  axis_limit_A = max(1.5, 1.8*n^2*a_A);

  fprintf('\nTASK 10: HYDROGENIC ORBITALS\n');
  fprintf('------------------------------------------------------------\n');
  fprintf('Z=%d, A=%d, n=%d, l=%d, m=%d\n', Z, A, n, l, m);
  fprintf('Orbital: %d%s, m=%d\n', n, label, m);
  fprintf('Hydrogenic radius a = %.6f angstrom\n', a_A);
  fprintf('Orbital energy = %.6f eV\n\n', energy_eV);

  % Fig 1: 2D sices and radial probability

  coordinate_A = linspace(-axis_limit_A, axis_limit_A, grid_2D);
  [U_A, V_A] = meshgrid(coordinate_A, coordinate_A);
  ZEROS = zeros(size(U_A));

  [~, density_xy] = hydrogenic_wavefunction(U_A, V_A, ZEROS, Z, A, n, l, m);
  [~, density_xz] = hydrogenic_wavefunction(U_A, ZEROS, V_A, Z, A, n, l, m);
  [~, density_yz] = hydrogenic_wavefunction(ZEROS, U_A, V_A, Z, A, n, l, m);

  maximum_density = max([density_xy(:); density_xz(:); density_yz(:)]);
  if maximum_density == 0
    maximum_density = 1;
  endif

  density_xy = density_xy / maximum_density;
  density_xz = density_xz / maximum_density;
  density_yz = density_yz / maximum_density;

  radial_A = linspace(0, 1.25*axis_limit_A, 1400);
  radial_m = radial_A * 1e-10;
  radial_R = hydrogenic_radial(radial_m, Z, A, n, l);
  radial_probability = radial_m.^2 .* abs(radial_R).^2;
  if max(radial_probability) > 0
    radial_probability = radial_probability / max(radial_probability);
  endif

  fig1 = figure('Name', 'Task 10 - Hydrogenic Orbital Slices', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [35 65 1200 760]);

  subplot(2,2,1);
  imagesc(coordinate_A, coordinate_A, density_xy);
  axis image; axis xy; caxis([0 1]); colorbar();
  xlabel('y / angstrom'); ylabel('z / angstrom');
  title('x-y plane, z=0', 'FontWeight', 'bold');

  subplot(2,2,2);
  imagesc(coordinate_A, coordinate_A, density_xz);
  axis image; axis xy; caxis([0 1]); colorbar();
  xlabel('x / angstrom'); ylabel('z / angstrom');
  title('x-z plane, y=0', 'FontWeight', 'bold');

  subplot(2,2,3);
  imagesc(coordinate_A, coordinate_A, density_yz);
  axis image; axis xy; caxis([0 1]); colorbar();
  xlabel('y / angstrom'); ylabel('z / angstrom');
  title('y-z plane, x=0', 'FontWeight', 'bold');

  subplot(2,2,4);
  plot(radial_A, radial_probability, 'r-', 'LineWidth', 2);
  xlabel('Radius, r / angstrom');
  ylabel('Normalised r^2|R_{nl}(r)|^2');
  title('Radial Probability Distribution', 'FontWeight', 'bold');
  grid on; box on; ylim([0 1.05]);

  full_title = sprintf('%d%s orbital, m=%d, Z=%d, E=%.4f eV', n, label, m, Z, energy_eV);

  annotation(fig1, 'textbox', [0.18 0.945 0.64 0.04], 'String', full_title, 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold', 'EdgeColor', 'none');

  colormap(fig1, jet(256));
  set(fig1, 'PaperPositionMode', 'auto');
  drawnow();
  print(fig1, fullfile(savedir, 'hydrogenic_orbital_slices.png'), '-dpng', '-r300');

  % FIGURE 2: COLOURED-GLASS Z SLICES

  glass_axis_A = linspace(-axis_limit_A, axis_limit_A, 111);
  [GX_A, GY_A] = meshgrid(glass_axis_A, glass_axis_A);
  slice_z_A = linspace(-axis_limit_A, axis_limit_A, number_of_slices);

  slice_density = cell(1, number_of_slices);
  glass_maximum = 0;

  for s = 1:number_of_slices
    GZ_A = slice_z_A(s) * ones(size(GX_A));
    [~, D] = hydrogenic_wavefunction(GX_A, GY_A, GZ_A, Z, A, n, l, m);
    slice_density{s} = D;
    glass_maximum = max(glass_maximum, max(D(:)));
  endfor

  if glass_maximum == 0
    glass_maximum = 1;
  endif

  fig2 = figure('Name', 'Task 10 - Coloured Glass Orbital', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [90 75 900 760]);
  hold on;

  for s = 1:number_of_slices
    D = slice_density{s} / glass_maximum;
    D(D < threshold) = NaN;

    surface_handle = surf(GX_A, GY_A, slice_z_A(s)*ones(size(GX_A)), D, 'EdgeColor', 'none');

    try
      set(surface_handle, 'FaceAlpha', 0.30);
    catch
      % Some graphics toolkits do not support transparency.
    end_try_catch
  endfor

  xlabel('x / angstrom');
  ylabel('y / angstrom');
  zlabel('z / angstrom');
  title({full_title, sprintf('Coloured-glass z slices, threshold=%.2f', threshold)}, 'FontSize', 13, 'FontWeight', 'bold');
  axis equal;
  axis([-axis_limit_A axis_limit_A -axis_limit_A axis_limit_A -axis_limit_A axis_limit_A]);
  grid on; box on; view(38,27);
  colormap(fig2, jet(256)); colorbar(); caxis([0 1]);

  set(fig2, 'PaperPositionMode', 'auto');
  drawnow();
  print(fig2, fullfile(savedir, 'hydrogenic_orbital_coloured_glass.png'), '-dpng', '-r300');

  % FIGURE 3: PHASE-COLOURED 3D ISOSURFACE

  coordinate_3D_A = linspace(-axis_limit_A, axis_limit_A, grid_3D);
  [X3_A, Y3_A, Z3_A] = meshgrid(coordinate_3D_A, coordinate_3D_A, coordinate_3D_A);

  [psi_3D, ~] = hydrogenic_wavefunction(X3_A, Y3_A, Z3_A, Z, A, n, l, m);
  maximum_psi = max(abs(psi_3D(:)));
  if maximum_psi == 0
    maximum_psi = 1;
  endif

  psi_3D = psi_3D / maximum_psi;
  amplitude_level = sqrt(threshold);

  fig3 = figure('Name', 'Task 10 - Hydrogenic Orbital Isosurface', 'NumberTitle', 'off', 'Color', [1 1 1], 'Position', [135 85 900 760]);
  hold on;

  positive_surface = isosurface(X3_A, Y3_A, Z3_A, psi_3D, amplitude_level);
  if !isempty(positive_surface.vertices)
    positive_patch = patch(positive_surface);
    set(positive_patch, 'FaceColor', [0.85 0.15 0.12], 'EdgeColor', 'none', 'FaceAlpha', 0.72);
  endif

  negative_surface = isosurface(X3_A, Y3_A, Z3_A, psi_3D, -amplitude_level);
  if !isempty(negative_surface.vertices)
    negative_patch = patch(negative_surface);
    set(negative_patch, 'FaceColor', [0.15 0.35 0.90], 'EdgeColor', 'none', 'FaceAlpha', 0.72);
  endif

  try
    camlight('headlight');
    lighting gouraud;
  catch
  end_try_catch

  xlabel('x / angstrom');
  ylabel('y / angstrom');
  zlabel('z / angstrom');
  title({full_title, 'Red and blue show opposite wavefunction phases'}, 'FontSize', 13, 'FontWeight', 'bold');
  axis equal;
  axis([-axis_limit_A axis_limit_A -axis_limit_A axis_limit_A -axis_limit_A axis_limit_A]);
  grid on; box on; view(40,28);

  set(fig3, 'PaperPositionMode', 'auto');
  drawnow();
  print(fig3, fullfile(savedir, 'hydrogenic_orbital_isosurface.png'), '-dpng', '-r300');

  % CSV export
  filename = fullfile(savedir, 'hydrogenic_orbital_xy_density.csv');
  fid = fopen(filename, 'w');

  if fid == -1
    error('Could not open CSV file for writing: %s', filename);
  endif

  fprintf(fid, 'x_angstrom,y_angstrom,normalised_probability_density\n');

  for row = 1:size(U_A,1)
    for column = 1:size(U_A,2)
      fprintf(fid, '%.8f,%.8f,%.10e\n', U_A(row,column), V_A(row,column), density_xy(row,column));
    endfor
  endfor

  fclose(fid);

  fprintf('Saved outputs:\n');
  fprintf('  hydrogenic_orbital_slices.png\n');
  fprintf('  hydrogenic_orbital_coloured_glass.png\n');
  fprintf('  hydrogenic_orbital_isosurface.png\n');
  fprintf('  hydrogenic_orbital_xy_density.csv\n\n');
endfunction


function [psi, density] = hydrogenic_wavefunction(x_A, y_A, z_A, Z, A, n, l, m)
  x_m = x_A * 1e-10;
  y_m = y_A * 1e-10;
  z_m = z_A * 1e-10;

  radius_m = sqrt(x_m.^2 + y_m.^2 + z_m.^2);
  cos_theta = ones(size(radius_m));
  nonzero = radius_m > 0;
  cos_theta(nonzero) = z_m(nonzero) ./ radius_m(nonzero);
  cos_theta = min(1, max(-1, cos_theta));
  phi = atan2(y_m, x_m);

  radial = hydrogenic_radial(radius_m, Z, A, n, l);
  angular = real_spherical_harmonic(l, m, cos_theta, phi);

  psi = radial .* angular;
  density = abs(psi).^2;
endfunction


function radial = hydrogenic_radial(radius_m, Z, A, n, l)
  h = 6.62607015e-34;
  hbar = h / (2*pi);
  e = 1.602176634e-19;
  epsilon_0 = 8.8541878128e-12;
  m_e = 9.1093837015e-31;
  u = 1.66053906660e-27;

  nucleus_mass = A * u;
  reduced_mass = m_e * nucleus_mass / (m_e + nucleus_mass);
  a_0 = 4*pi*epsilon_0*hbar^2 / (m_e*e^2);
  a = (m_e/reduced_mass) * a_0 / Z;

  scaled_radius = 2 .* radius_m ./ (n*a);
  order = n-l-1;
  alpha = 2*l+1;
  L = generalized_laguerre(order, alpha, scaled_radius);

  prefactor = sqrt(factorial(n-l-1)/(2*n*factorial(n+l))) * (2/(n*a))^(3/2);

  radial = prefactor .* scaled_radius.^l .* exp(-scaled_radius/2) .* L;
endfunction


function value = generalized_laguerre(order, alpha, x)
  value = zeros(size(x));

  for k = 0:order
    coefficient = (-1)^k * factorial(order+alpha) / (factorial(order-k)*factorial(alpha+k)*factorial(k));

    value += coefficient .* x.^k;
  endfor
endfunction


function angular = real_spherical_harmonic(l, m, cos_theta, phi)
  absolute_m = abs(m);
  P = associated_legendre_array(l, absolute_m, cos_theta);

  normalisation = sqrt((2*l+1)/(4*pi) * factorial(l-absolute_m)/factorial(l+absolute_m));

  if m > 0
    angular = sqrt(2) .* normalisation .* P .* cos(absolute_m.*phi);
  elseif m < 0
    angular = sqrt(2) .* normalisation .* P .* sin(absolute_m.*phi);
  else
    angular = normalisation .* P;
  endif
endfunction


function P_lm = associated_legendre_array(l, m, x)
  P_mm = ones(size(x));

  if m > 0
    P_mm = (-1)^m * double_factorial(2*m-1) .* max(0, 1-x.^2).^(m/2);
  endif

  if l == m
    P_lm = P_mm;
    return;
  endif

  P_m1m = x .* (2*m+1) .* P_mm;

  if l == m+1
    P_lm = P_m1m;
    return;
  endif

  P_old = P_mm;
  P_now = P_m1m;

  for current_l = m+2:l
    P_new = ((2*current_l-1).*x.*P_now - (current_l+m-1).*P_old) / (current_l-m);
    P_old = P_now;
    P_now = P_new;
  endfor

  P_lm = P_now;
endfunction


function value = double_factorial(number)
  if number <= 0
    value = 1;
  else
    value = prod(number:-2:1);
  endif
endfunction


function label = orbital_label(l)
  labels = {'S','P','D','F','G','H','I','K'};

  if l+1 <= length(labels)
    label = labels{l+1};
  else
    label = sprintf('l%d', l);
  endif
endfunction
