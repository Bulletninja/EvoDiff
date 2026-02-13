function plot_ablation_waterfall(results, save_path)
% PLOT_ABLATION_WATERFALL Waterfall chart showing cumulative component contribution
%
% Each bar shows the ARPD delta from adding one algorithm component.
% Variants must be ordered from baseline to full hybrid (cumulative additions).
% Green bars = improvement (negative delta), red bars = degradation.
%
% Args:
%   results   - Struct array from run_experiment() with ablation variants
%   save_path - File path to save the figure (optional)

    num_problems = length(results);
    num_variants = length(results(1).variants);

    % Compute ARPD for each variant
    arpd = zeros(num_variants, 1);
    variant_names = cell(num_variants, 1);
    for v = 1:num_variants
        variant_names{v} = results(1).variants(v).name;
        total_rpd = 0;
        for p = 1:num_problems
            fv = results(p).variants(v).stats.vals(:, end);
            total_rpd = total_rpd + 100 * (mean(fv) - results(p).ub) / results(p).ub;
        end
        arpd(v) = total_rpd / num_problems;
    end

    % Compute deltas
    deltas = diff(arpd);

    fig = figure('Visible', 'off', 'Position', [100 100 700 450]);
    hold on;

    bar_width = 0.6;
    green = [0.20 0.66 0.33];
    red = [0.84 0.24 0.24];
    gray = [0.55 0.55 0.55];

    % First bar: baseline (solid from 0)
    rectangle('Position', [1 - bar_width/2, 0, bar_width, arpd(1)], ...
        'FaceColor', gray, 'EdgeColor', 'k', 'LineWidth', 1);
    text(1, arpd(1) + 0.15, sprintf('%.2f', arpd(1)), ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');

    % Delta bars (floating)
    running = arpd(1);
    for i = 2:num_variants
        d = deltas(i-1);
        if d <= 0
            % Improvement: bar hangs down from running level
            bottom = running + d;
            height = abs(d);
            col = green;
        else
            % Degradation: bar goes up from running level
            bottom = running;
            height = d;
            col = red;
        end

        rectangle('Position', [i - bar_width/2, bottom, bar_width, height], ...
            'FaceColor', col, 'EdgeColor', 'k', 'LineWidth', 1);

        % Delta label inside or above bar
        mid_y = bottom + height / 2;
        label = sprintf('%+.2f', d);
        if height > 0.3
            text(i, mid_y, label, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontSize', 9, 'FontWeight', 'bold', 'Color', 'w');
        else
            text(i, bottom + height + 0.12, label, ...
                'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
        end

        % Connector line from previous bar to this one
        plot([i - 1 + bar_width/2, i - bar_width/2], [running, running], ...
            'k--', 'LineWidth', 0.8);

        % Result label at the new level
        running = running + d;
        text(i, running - 0.15, sprintf('%.2f', running), ...
            'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', [0.3 0.3 0.3]);
    end

    hold off;
    set(gca, 'XTick', 1:num_variants, 'XTickLabel', variant_names);
    ylabel('ARPD (%)');
    title('Ablation Study — Component Contribution');
    grid on;
    set(gca, 'XTickLabelRotation', 15);

    % Y limits with padding
    ylim([min(0, min(arpd)) - 0.5, max(arpd) + 0.8]);

    if nargin >= 2 && ~isempty(save_path)
        print(fig, save_path, '-dpng', '-r200');
    end
    close(fig);
end
