function task8_quantum_cryptography()

  % Task 8: Quantum cryptography mismatch calculator

  % Comapres the classical and quantum mismatch probabilities for two polarizatin detector angles theta and phi

  % Classical model:
  % P_mismatch = 1 - cos^2(theta)cos^2(phi) - sin^2(theta)sin^2(phi)

  % Quantum model:
  % P_mismatch = sin^2(phi - theta)

  % All angles are inputted in degrees

  close all;
  clc;

  % GUI
  fig = figure('Name', 'Task 8 - Quantum Cryptography', 'NumberTitle', 'off', 'Color', [0.94 0.94 0.94], 'Position', [45 45 1180 720]);

  % Main Axes
  detector_ax = axes('Parent', fig, 'Position', [0.055 0.49 0.37 0.43]);

  curve_ax = axes('Parent', fig, 'Position', [0.50 0.52 0.45 0.40]);

  bar_ax = axes('Parent', fig, 'Position', [0.055 0.20 0.37 0.21]);

  difference_ax = axes('Parent', fig, 'Position', [0.50 0.20 0.45 0.24]);

  % Control panel
  control_panel = uipanel('Parent', fig, 'Units', 'normalized', 'Position', [0.04 0.025 0.92 0.12], 'Title', 'Detector angles', 'FontWeight', 'bold', 'BackgroundColor', [0.90 0.90 0.90]);

  uicontrol('Parent', control_panel, 'Style', 'text', 'Units', 'normalized', 'Position', [0.02 0.57 0.10 0.23], 'String', 'Detector A, theta:', 'HorizontalAlignment', 'left', 'BackgroundColor', [0.90 0.90 0.90]);

  theta_slider = uicontrol('Parent', control_panel, 'Style', 'slider', 'Units', 'normalized', 'Position', [0.13 0.61 0.30 0.18], 'Min', -90, 'Max', 90, 'Value', -30, 'SliderStep', [1/180 10/180], 'Callback', @update_app);

  theta_label = uicontrol('Parent', control_panel, 'Style', 'text', 'Units', 'normalized', 'Position', [0.44 0.55 0.08 0.28], 'String', 'theta = -30 deg', 'BackgroundColor', [1 1 1], 'FontWeight', 'bold');

  uicontrol('Parent', control_panel, 'Style', 'text', 'Units', 'normalized', 'Position', [0.02 0.16 0.10 0.23], 'String', 'Detector B, phi:', 'HorizontalAlignment', 'left', 'BackgroundColor', [0.90 0.90 0.90]);

  phi_slider = uicontrol('Parent', control_panel, 'Style', 'slider', 'Units', 'normalized', 'Position', [0.13 0.20 0.30 0.18], 'Min', -90, 'Max', 90, 'Value', 30, 'SliderStep', [1/180 10/180], 'Callback', @update_app);

  phi_label = uicontrol('Parent', control_panel, 'Style', 'text', 'Units', 'normalized', 'Position', [0.44 0.14 0.08 0.28], 'String', 'phi = 30 deg', 'BackgroundColor', [1 1 1], 'FontWeight', 'bold');

  result_text = uicontrol('Parent', control_panel, 'Style', 'text', 'Units', 'normalized', 'Position', [0.55 0.13 0.29 0.70], 'String', '', 'BackgroundColor', [1.00 1.00 0.84], 'HorizontalAlignment', 'left', 'FontName', 'Courier New', 'FontSize', 10);

  uicontrol('Parent', control_panel, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.86 0.54 0.11 0.28], 'String', 'Reset example', 'Callback', @reset_example);

  uicontrol('Parent', control_panel, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.86 0.15 0.11 0.28], 'String', 'Save Figure', 'Callback', @save_figure);

  update_app();

  % Callbacks

  function update_app(src, evt)
    theta_deg = round(get(theta_slider, 'Value'));
    phi_deg = round(get(phi_slider, 'Value'));

    set(theta_slider, 'Value', theta_deg);
    set(phi_slider, 'Value', phi_deg);

    set(theta_label, 'String', sprintf('theta = %d deg', theta_deg));
    set(phi_label, 'String', sprintf('phi = %d deg', phi_deg));

    [classical_mismatch, quantum_mismatch] = mismatch_probabilities(theta_deg, phi_deg);

    difference = quantum_mismatch - classical_mismatch;

    result_string = sprintf(['Classical mismatch = %.5f/n', 'Quantum mismatch = %.5f/n', 'Difference Q - C = %+.5f/n', 'Relative angle = %d deg'], classical_mismatch, quantum_mismatch, difference, phi_deg - theta_deg);

    set(result_text, 'String', result_string);

    draw_detectors(theta_deg, phi_deg);
    draw_probability_curves(theta_deg, phi_deg);
    draw_probability_bars(classical_mismatch, quantum_mismatch);
    draw_difference_map(theta_deg, phi_deg);
  endfunction

  function reset_example(src, evt)
    set(theta_slider, 'Value', -30);
    set(phi_slider, 'Value', 30);
    update_app();
  endfunction

  function save_figure(src, evt)
    set(fig, 'PaperPositionMode', 'auto');
    print(fig, 'quantum_cryptography_calculator.png', '-dpng', '-r250');
  endfunction

  % Drawings
  function draw_detectors(theta_deg, phi_deg)
    cla(detector_ax);
    hold(detector_ax, 'on');
    axis(detector_ax, 'equal');
    axis(detector_ax, [-1.15 1.15 -0.82 0.95]);
    axis(detector_ax, 'off');

    title(detector_ax, 'Polarization Detector Orientations', 'FontSize', 13, 'FontWeight', 'bold');

    % Entangled photon source.
    plot(detector_ax, [0 0], [-0.18 0.40], 'r-', 'LineWidth', 3);
    plot(detector_ax, [0 0], [-0.18 -0.48], 'r-', 'LineWidth', 3);

    arrow_line(detector_ax, 0, 0.08, -0.30, 0.08, [0.15 0.45 0.80]);
    arrow_line(detector_ax, 0, 0.08,  0.30, 0.08, [0.15 0.45 0.80]);

    text(detector_ax, 0, 0.57, 'Entangled photon pair', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

    % Detector centres.
    left_centre = [-0.72, 0.02];
    right_centre = [0.72, 0.02];
    axis_length = 0.34;

    draw_detector_axes(detector_ax, left_centre, theta_deg, axis_length, [0.05 0.65 0.25], 'Detector A', '\theta');

    draw_detector_axes(detector_ax, right_centre, phi_deg, axis_length, [0.15 0.40 0.85], 'Detector B', '\phi');

    text(detector_ax, -0.72, -0.68, sprintf('\\theta = %d^\\circ', theta_deg), 'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');

    text(detector_ax, 0.72, -0.68, sprintf('\\phi = %d^\\circ', phi_deg), 'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
  endfunction


  function draw_probability_curves(theta_deg, phi_deg)
    cla(curve_ax);
    hold(curve_ax, 'on');

    phi_range = linspace(-90, 90, 721);

    classical_curve = 1 - cosd(theta_deg).^2 .* cosd(phi_range).^2 - sind(theta_deg).^2 .* sind(phi_range).^2;

    quantum_curve = sind(phi_range - theta_deg).^2;

    plot(curve_ax, phi_range, classical_curve, 'Color', [0.15 0.45 0.85], 'LineWidth', 2);

    plot(curve_ax, phi_range, quantum_curve, 'Color', [0.90 0.20 0.15], 'LineWidth', 2);

    [classical_now, quantum_now] = mismatch_probabilities(theta_deg, phi_deg);

    plot(curve_ax, phi_deg, classical_now, 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0.15 0.45 0.85], 'MarkerEdgeColor', [0.15 0.45 0.85]);

    plot(curve_ax, phi_deg, quantum_now, 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0.90 0.20 0.15], 'MarkerEdgeColor', [0.90 0.20 0.15]);

    xlabel(curve_ax, 'Detector B angle, \phi / degrees');
    ylabel(curve_ax, 'Mismatch probability');

    title(curve_ax, sprintf('Mismatch vs \\phi for fixed \\theta = %d^\\circ', theta_deg), 'FontSize', 12, 'FontWeight', 'bold');

    legend(curve_ax, {'Classical model', 'Quantum model'}, 'Location', 'northwest');

    xlim(curve_ax, [-90 90]);
    ylim(curve_ax, [0 1]);
    grid(curve_ax, 'on');
    box(curve_ax, 'on');
  endfunction


  function draw_probability_bars(classical_value, quantum_value)
    cla(bar_ax);

    values = [classical_value quantum_value];

    bar(bar_ax, values, 0.55);
    set(bar_ax, 'XTick', [1 2], 'XTickLabel', {'Classical', 'Quantum'}, 'YLim', [0 1], 'FontSize', 10);

    ylabel(bar_ax, 'Mismatch probability');
    title(bar_ax, 'Current Classical and Quantum Predictions', 'FontSize', 12, 'FontWeight', 'bold');

    grid(bar_ax, 'on');
    box(bar_ax, 'on');

    text(bar_ax, 1, classical_value + 0.04, sprintf('%.4f', classical_value), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

    text(bar_ax, 2, quantum_value + 0.04, sprintf('%.4f', quantum_value), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
  endfunction


  function draw_difference_map(theta_deg, phi_deg)
    cla(difference_ax);

    angle_values = -90:2:90;
    [theta_grid, phi_grid] = meshgrid(angle_values, angle_values);

    classical_grid = 1 - cosd(theta_grid).^2 .* cosd(phi_grid).^2 - sind(theta_grid).^2 .* sind(phi_grid).^2;

    quantum_grid = sind(phi_grid - theta_grid).^2;
    difference_grid = quantum_grid - classical_grid;

    imagesc(difference_ax, angle_values, angle_values, difference_grid);
    axis(difference_ax, 'xy');
    hold(difference_ax, 'on');

    plot(difference_ax, theta_deg, phi_deg, 'wo', 'MarkerSize', 9, 'LineWidth', 2);

    xlabel(difference_ax, '\theta / degrees');
    ylabel(difference_ax, '\phi / degrees');

    title(difference_ax, 'Quantum minus Classical Mismatch', 'FontSize', 12, 'FontWeight', 'bold');

    colorbar('peer', difference_ax);
    caxis(difference_ax, [-0.5 0.5]);
    colormap(difference_ax, jet(256));
  endfunction

  % Helper functions
  function [p_classical, p_quantum] = mismatch_probabilities(theta_deg, phi_deg)

    p_classical = 1 - cosd(theta_deg)^2 * cosd(phi_deg)^2 - sind(theta_deg)^2 * sind(phi_deg)^2;

    p_quantum = sind(phi_deg - theta_deg)^2;
  endfunction


  function draw_detector_axes(ax, centre, angle_deg, length_value, colour, detector_name, angle_symbol)

    angle_rad = angle_deg * pi / 180;

    x_direction = [cos(angle_rad), sin(angle_rad)];
    y_direction = [-sin(angle_rad), cos(angle_rad)];

    arrow_line(ax, centre(1), centre(2), centre(1) + length_value*x_direction(1), centre(2) + length_value*x_direction(2), colour);

    arrow_line(ax, centre(1), centre(2), centre(1) + length_value*y_direction(1), centre(2) + length_value*y_direction(2), colour);

    plot(ax, centre(1), centre(2), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);

    text(ax, centre(1), centre(2) - 0.43, detector_name, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

    text(ax, centre(1) + 0.12, centre(2) + 0.16, angle_symbol, 'FontSize', 12, 'Color', colour);
  endfunction


  function arrow_line(ax, x1, y1, x2, y2, colour)
    plot(ax, [x1 x2], [y1 y2], 'Color', colour, 'LineWidth', 1.8);

    angle = atan2(y2-y1, x2-x1);
    arrow_size = 0.055;

    plot(ax, [x2, x2-arrow_size*cos(angle-pi/6)], [y2, y2-arrow_size*sin(angle-pi/6)], 'Color', colour, 'LineWidth', 1.8);

    plot(ax, [x2, x2-arrow_size*cos(angle+pi/6)], [y2, y2-arrow_size*sin(angle+pi/6)], 'Color', colour, 'LineWidth', 1.8);
  endfunction
endfunction


