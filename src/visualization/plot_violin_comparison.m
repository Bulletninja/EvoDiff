function plot_violin_comparison(results, save_path)
% PLOT_VIOLIN_COMPARISON Violin plots of final RPD per variant
%
% Shows the full distribution of RPD values across all runs and problems
% for each variant. Falls back to boxplot if statistics package unavailable.
%
% Args:
%   results   - Struct array from run_experiment()
%   save_path - File path to save the figure (optional)

    num_problems = length(results);
    num_variants = length(results(1).variants);

    % Collect all final RPD values per variant
    rpd_data = {};
    variant_names = {};
    for v = 1:num_variants
        variant_names{v} = results(1).variants(v).name;
        all_rpd = [];
        for p = 1:num_problems
            fv = results(p).variants(v).stats.vals(:, end);
            rpd_vals = 100 * (fv - results(p).ub) / results(p).ub;
            all_rpd = [all_rpd; rpd_vals];
        end
        rpd_data{v} = all_rpd;
    end

    % Pad to equal length for matrix form
    max_len = max(cellfun(@length, rpd_data));
    rpd_matrix = NaN(max_len, num_variants);
    for v = 1:num_variants
        rpd_matrix(1:length(rpd_data{v}), v) = rpd_data{v};
    end

    fig = figure('Visible', 'off', 'Position', [100 100 500 400]);

    % Try violin plot, fall back to boxplot
    has_violin = false;
    try
        pkg load statistics;
        violin(rpd_matrix);
        has_violin = true;
    catch
        try
            boxplot(rpd_matrix);
        catch
            % Manual boxplot fallback
            for v = 1:num_variants
                d = rpd_data{v};
                q = quantile(d, [0.25 0.5 0.75]);
                iqr_val = q(3) - q(1);
                lo = max(min(d), q(1) - 1.5 * iqr_val);
                hi = min(max(d), q(3) + 1.5 * iqr_val);
                % Box
                rectangle('Position', [v - 0.3, q(1), 0.6, q(3) - q(1)], ...
                    'EdgeColor', 'k', 'LineWidth', 1.5);
                % Median
                line([v - 0.3, v + 0.3], [q(2), q(2)], 'Color', 'r', 'LineWidth', 2);
                % Whiskers
                line([v, v], [lo, q(1)], 'Color', 'k');
                line([v, v], [q(3), hi], 'Color', 'k');
            end
        end
    end

    % Overlay jittered data points
    hold on;
    for v = 1:num_variants
        d = rpd_data{v};
        jitter = 0.12 * (rand(length(d), 1) - 0.5);
        scatter(v + jitter, d, 8, [0.3 0.3 0.3], 'filled');
    end
    hold off;

    set(gca, 'XTick', 1:num_variants, 'XTickLabel', variant_names);
    ylabel('RPD (%)');
    title('RPD Distribution by Variant');

    if nargin >= 2 && ~isempty(save_path)
        print(fig, save_path, '-dpng', '-r200');
    end
    close(fig);
end
