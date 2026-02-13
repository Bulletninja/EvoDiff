function plot_convergence_bands(results, problem_idx, save_path)
% PLOT_CONVERGENCE_BANDS Convergence curves with shaded confidence bands
%
% Plots mean convergence per variant with 10th-90th percentile bands.
% LB and UB reference lines included.
%
% Args:
%   results     - Struct array from run_experiment()
%   problem_idx - Index of the problem to plot
%   save_path   - File path to save the figure (optional)

    num_variants = length(results(problem_idx).variants);
    colors = {[0.12 0.47 0.71], [1.0 0.5 0.05], [0.17 0.63 0.17], ...
              [0.84 0.15 0.16], [0.58 0.40 0.74], [0.55 0.34 0.29]};

    fig = figure('Visible', 'off', 'Position', [100 100 700 450]);
    hold on;
    legend_handles = [];
    legend_labels = {};

    for v = 1:num_variants
        vals = results(problem_idx).variants(v).stats.vals;
        max_gen = size(vals, 2);
        x = 1:max_gen;

        c = colors{mod(v-1, length(colors)) + 1};

        upper = prctile(vals, 90, 1);
        lower = prctile(vals, 10, 1);
        mu = mean(vals, 1);

        % Draw band with transparency
        patch([x, fliplr(x)], [upper, fliplr(lower)], c, ...
            'EdgeColor', 'none', 'FaceAlpha', 0.25);

        % Draw mean line
        h = plot(x, mu, 'Color', c, 'LineWidth', 2);
        legend_handles(end+1) = h;
        legend_labels{end+1} = results(problem_idx).variants(v).name;
    end

    % Reference lines
    xl = xlim();
    h_lb = plot(xl, [results(problem_idx).lb results(problem_idx).lb], 'g--', 'LineWidth', 1);
    h_ub = plot(xl, [results(problem_idx).ub results(problem_idx).ub], 'k--', 'LineWidth', 1);
    legend_handles(end+1) = h_lb;
    legend_labels{end+1} = 'LB';
    legend_handles(end+1) = h_ub;
    legend_labels{end+1} = 'UB';

    hold off;
    legend(legend_handles, legend_labels{:}, 'Location', 'northeast');
    title(sprintf('Problem %d — Convergence (shaded: 10th-90th percentile)', problem_idx));
    xlabel('Generation');
    ylabel('Best Makespan');
    grid on;

    if nargin >= 3 && ~isempty(save_path)
        print(fig, save_path, '-dpng', '-r200');
    end
    close(fig);
end
