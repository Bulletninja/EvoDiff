function plot_heat_matrix(results, save_path)
% PLOT_HEAT_MATRIX Variant x problem RPD heatmap with annotations
%
% Rows = algorithm variants, columns = problem instances.
% Cell color = mean RPD, annotated with numeric values.
%
% Args:
%   results   - Struct array from run_experiment()
%   save_path - File path to save the figure (optional)

    num_problems = length(results);
    num_variants = length(results(1).variants);

    % Build RPD matrix (variants x problems)
    rpd_matrix = zeros(num_variants, num_problems);
    variant_names = cell(1, num_variants);
    for v = 1:num_variants
        variant_names{v} = results(1).variants(v).name;
        for p = 1:num_problems
            fv = results(p).variants(v).stats.vals(:, end);
            rpd_matrix(v, p) = 100 * (mean(fv) - results(p).ub) / results(p).ub;
        end
    end

    % Add ARPD column
    arpd = mean(rpd_matrix, 2);
    display_matrix = [rpd_matrix, arpd];
    num_cols = num_problems + 1;

    % Build diverging colormap (green-white-red)
    n = 128;
    green_to_white = [linspace(0.2, 1, n)', linspace(0.7, 1, n)', linspace(0.2, 1, n)'];
    white_to_red = [linspace(1, 0.8, n)', linspace(1, 0.2, n)', linspace(1, 0.2, n)'];
    div_cmap = [green_to_white; white_to_red];

    fig = figure('Visible', 'off', 'Position', [100 100 max(600, num_cols * 55 + 100) num_variants * 60 + 120]);
    imagesc(display_matrix);
    colorbar;
    colormap(div_cmap);

    % Set color limits symmetric around median
    med_val = median(display_matrix(:));
    max_dev = max(abs(display_matrix(:) - med_val));
    if max_dev > 0
        caxis([med_val - max_dev, med_val + max_dev]);
    end

    % Annotate cells
    for i = 1:num_variants
        for j = 1:num_cols
            val = display_matrix(i, j);
            % Pick text color for contrast
            if val > med_val
                txt_color = [1 1 1];
            else
                txt_color = [0 0 0];
            end
            text(j, i, sprintf('%.2f', val), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'FontSize', 9, 'FontWeight', 'bold', 'Color', txt_color);
        end
    end

    % Draw separator line before ARPD column
    hold on;
    plot([num_problems + 0.5, num_problems + 0.5], [0.5, num_variants + 0.5], ...
        'k-', 'LineWidth', 2);
    hold off;

    % Labels
    col_labels = arrayfun(@(x) sprintf('P%d', x), 1:num_problems, 'UniformOutput', false);
    col_labels{end+1} = 'ARPD';
    set(gca, 'XTick', 1:num_cols, 'XTickLabel', col_labels);
    set(gca, 'YTick', 1:num_variants, 'YTickLabel', variant_names);
    title('Mean RPD (%) — Variant x Problem');

    if nargin >= 2 && ~isempty(save_path)
        print(fig, save_path, '-dpng', '-r200');
    end
    close(fig);
end
