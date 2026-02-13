function plot_bump_chart(results, save_path)
% PLOT_BUMP_CHART Rank of each variant across problem instances
%
% X-axis = problem, Y-axis = rank (1 at top). Each variant is a line
% connecting its ranks. Shows rank stability across problems.
%
% Args:
%   results   - Struct array from run_experiment()
%   save_path - File path to save the figure (optional)

    num_problems = length(results);
    num_variants = length(results(1).variants);
    colors = {[0.12 0.47 0.71], [1.0 0.5 0.05], [0.17 0.63 0.17], ...
              [0.84 0.15 0.16], [0.58 0.40 0.74], [0.55 0.34 0.29]};

    % Compute mean RPD per variant per problem
    rpd = zeros(num_variants, num_problems);
    for v = 1:num_variants
        for p = 1:num_problems
            fv = results(p).variants(v).stats.vals(:, end);
            rpd(v, p) = 100 * (mean(fv) - results(p).ub) / results(p).ub;
        end
    end

    % Compute ranks per problem (1 = best = lowest RPD)
    ranks = zeros(num_variants, num_problems);
    for p = 1:num_problems
        [~, idx] = sort(rpd(:, p));
        ranks(idx, p) = 1:num_variants;
    end

    fig = figure('Visible', 'off', 'Position', [100 100 600 350]);
    hold on;
    legend_labels = {};

    for v = 1:num_variants
        c = colors{mod(v-1, length(colors)) + 1};
        plot(1:num_problems, ranks(v, :), '-o', 'Color', c, ...
            'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', c);
        legend_labels{end+1} = results(1).variants(v).name;

        % Label at the right end
        text(num_problems + 0.3, ranks(v, num_problems), results(1).variants(v).name, ...
            'Color', c, 'FontSize', 9, 'VerticalAlignment', 'middle');
    end

    hold off;
    set(gca, 'YDir', 'reverse');
    set(gca, 'YTick', 1:num_variants);
    set(gca, 'XTick', 1:num_problems);
    xlabel('Problem');
    ylabel('Rank (1 = best)');
    title('Variant Ranking Across Problems');
    xlim([0.5, num_problems + 1.5]);
    ylim([0.5, num_variants + 0.5]);
    grid on;

    if nargin >= 2 && ~isempty(save_path)
        print(fig, save_path, '-dpng', '-r200');
    end
    close(fig);
end
