function generate_report(results, config)
% GENERATE_REPORT Generate LaTeX tables and convergence plots from results
%
% Args:
%   results - Struct array from run_experiment()
%   config  - Config struct from load_config()

    results_dir = config.results_dir;
    tables_dir = fullfile(results_dir, 'tables');
    figures_dir = fullfile(results_dir, 'figures');

    if ~exist(tables_dir, 'dir'), mkdir(tables_dir); end
    if ~exist(figures_dir, 'dir'), mkdir(figures_dir); end

    num_problems = length(results);

    for i = 1:num_problems
        % LaTeX table
        tex_file = fullfile(tables_dir, sprintf('taillard_%d.tex', i));
        fid = fopen(tex_file, 'w');
        % CR-115: check fopen success
        if fid == -1
            error('generate_report:openFailed', 'Cannot open %s for writing', tex_file);
        end
        % CR-106: ensure file handle is closed on error
        cleanup = onCleanup(@() fclose(fid));

        % CR-105: dynamic problem dimensions
        [prob_M, prob_N] = size(results(i).P);
        final_vals = results(i).stats.vals(:, end);
        best_val = min(final_vals);
        mean_val = mean(final_vals);
        median_val = median(final_vals);
        mean_errlb = mean(results(i).stats.errlb);

        fprintf(fid, '\\begin{table}[h]\n');
        fprintf(fid, '\\centering\n');
        fprintf(fid, '\\begin{tabular}{|l|r|}\n');
        fprintf(fid, '\\hline\n');
        fprintf(fid, '\\multicolumn{2}{|c|}{Taillard Flowshop (%dx%d) Problem %d} \\\\ \\hline\n', prob_N, prob_M, i);
        fprintf(fid, 'Lower Bound (LB) & %d \\\\ \\hline\n', results(i).lb);
        fprintf(fid, 'Upper Bound (UB) & %d \\\\ \\hline\n', results(i).ub);
        fprintf(fid, 'Best Found       & %.0f \\\\ \\hline\n', best_val);
        fprintf(fid, 'Mean             & %.1f \\\\ \\hline\n', mean_val);
        fprintf(fid, 'Median           & %.1f \\\\ \\hline\n', median_val);
        fprintf(fid, 'Mean Error (LB)  & %.1f \\\\ \\hline\n', mean_errlb);
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\\end{table}\n');
        clear cleanup;  % triggers fclose via onCleanup

        % Convergence plot
        fig = figure('Visible', 'off');
        hold on;
        plot(mean(results(i).stats.vals, 1), 'b-', 'LineWidth', 2);
        plot(mean(results(i).stats_selective.vals, 1), 'r-', 'LineWidth', 2);
        yline(results(i).lb, 'g--', 'LineWidth', 1);
        yline(results(i).ub, 'k--', 'LineWidth', 1);
        hold off;
        legend('Normal', 'Selective', 'LB', 'UB');
        title(sprintf('Problem %d Convergence', i));
        xlabel('Generation');
        ylabel('Best Makespan');
        grid on;
        saveas(fig, fullfile(figures_dir, sprintf('convergence_%d.png', i)));
        close(fig);
    end

    fprintf('Report generated: %d tables, %d plots\n', num_problems, num_problems);
end
