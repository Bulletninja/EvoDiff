function plot_performance_profile(results, save_path)
% PLOT_PERFORMANCE_PROFILE Dolan-More performance profile curves
%
% For each variant, plots the CDF of performance ratio across problems.
% The variant whose curve reaches 1.0 earliest is the most robust.
%
% Args:
%   results   - Struct array from run_experiment()
%   save_path - File path to save the figure (optional)

    num_problems = length(results);
    num_variants = length(results(1).variants);
    colors = {[0.12 0.47 0.71], [1.0 0.5 0.05], [0.17 0.63 0.17], ...
              [0.84 0.15 0.16], [0.58 0.40 0.74], [0.55 0.34 0.29]};

    % Compute mean makespan per variant per problem
    perf = zeros(num_variants, num_problems);
    for v = 1:num_variants
        for p = 1:num_problems
            perf(v, p) = mean(results(p).variants(v).stats.vals(:, end));
        end
    end

    % Compute performance ratios
    best_per_problem = min(perf, [], 1);
    ratios = zeros(num_variants, num_problems);
    for v = 1:num_variants
        ratios(v, :) = perf(v, :) ./ best_per_problem;
    end

    fig = figure('Visible', 'off', 'Position', [100 100 600 400]);
    hold on;
    legend_labels = {};

    for v = 1:num_variants
        sorted = sort(ratios(v, :));
        y = (1:num_problems) / num_problems;
        c = colors{mod(v-1, length(colors)) + 1};
        stairs([1, sorted], [0, y], 'Color', c, 'LineWidth', 2);
        legend_labels{end+1} = results(1).variants(v).name;
    end

    hold off;
    legend(legend_labels{:}, 'Location', 'southeast');
    xlabel('Performance ratio \tau');
    ylabel('Fraction of problems solved');
    title('Performance Profile (Dolan-More)');
    grid on;
    xlim([1, max(ratios(:)) * 1.02]);

    if nargin >= 2 && ~isempty(save_path)
        print(fig, save_path, '-dpng', '-r200');
    end
    close(fig);
end
