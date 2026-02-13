function generate_report(results, config)
% GENERATE_REPORT Generate LaTeX tables, convergence plots, and visualizations
%
% Produces per-problem tables, per-problem convergence plots with confidence
% bands, cross-variant comparison table, and additional visualizations:
% Gantt charts, heat matrix, performance profiles, violin plots, bump chart,
% machine utilization charts, ablation waterfall, and frequency animation.
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
    num_variants = length(results(1).variants);
    colors = {'b', 'r', 'm', [0 0.5 0], [0.8 0.4 0], [0 0.7 0.7]};

    % Per-problem tables and plots
    for i = 1:num_problems
        % LaTeX table (uses first variant for primary stats)
        tex_file = fullfile(tables_dir, sprintf('taillard_%d.tex', i));
        fid = fopen(tex_file, 'w');
        if fid == -1
            error('generate_report:openFailed', 'Cannot open %s for writing', tex_file);
        end
        cleanup = onCleanup(@() fclose(fid));

        [prob_M, prob_N] = size(results(i).P);
        final_vals = results(i).variants(1).stats.vals(:, end);
        best_val = min(final_vals);
        mean_val = mean(final_vals);
        median_val = median(final_vals);
        std_val = std(final_vals);
        mean_errlb = mean(results(i).variants(1).stats.errlb);
        rpd_best = 100 * (best_val - results(i).ub) / results(i).ub;
        rpd_mean = 100 * (mean_val - results(i).ub) / results(i).ub;

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
        fprintf(fid, 'Std Dev          & %.1f \\\\ \\hline\n', std_val);
        fprintf(fid, 'RPD Best (\\%%)   & %.2f \\\\ \\hline\n', rpd_best);
        fprintf(fid, 'RPD Mean (\\%%)   & %.2f \\\\ \\hline\n', rpd_mean);
        fprintf(fid, 'Mean Error (LB)  & %.1f \\\\ \\hline\n', mean_errlb);
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\\end{table}\n');
        clear cleanup;

        % Convergence plot with confidence bands
        plot_convergence_bands(results, i, ...
            fullfile(figures_dir, sprintf('convergence_%d.png', i)));

        % Gantt chart of best solution (first variant)
        % Run a quick DE — also capture population snapshots for problem 1
        try
            variant = config.variants(1);
            if i == 1
                [best_ind, ~, ~, ~, ~, ~, pop_snaps] = de_flowshop(results(i), ...
                    config.population_size, config.max_generations, ...
                    config.fitness_function, false, config.selection_ratio, variant);
            else
                [best_ind, ~, ~, ~, ~, ~] = de_flowshop(results(i), ...
                    config.population_size, config.max_generations, ...
                    config.fitness_function, false, config.selection_ratio, variant);
            end
            plot_gantt(results(i).P, best_ind, i, ...
                fullfile(figures_dir, sprintf('gantt_%d.png', i)));
            plot_machine_utilization(results(i).P, best_ind, i, ...
                fullfile(figures_dir, sprintf('utilization_%d.png', i)));
            % Animated Gantt for problem 1
            if i == 1
                animate_gantt(results(i).P, best_ind, i, ...
                    fullfile(figures_dir, 'gantt_animation.gif'));
            end
        catch e
            warning('generate_report:ganttFailed', ...
                'Gantt/utilization for problem %d skipped: %s', i, e.message);
        end
    end

    % Cross-variant comparison table
    if num_variants >= 2
        comp_file = fullfile(tables_dir, 'variant_comparison.tex');
        fid = fopen(comp_file, 'w');
        if fid == -1
            error('generate_report:openFailed', 'Cannot open %s for writing', comp_file);
        end
        cleanup = onCleanup(@() fclose(fid));

        % Build column spec: Problem | UB | (Best | RPD_mean) per variant
        col_spec = '|l|r|';
        for v = 1:num_variants
            col_spec = [col_spec, 'r|r|'];
        end

        fprintf(fid, '\\begin{table}[h]\n');
        fprintf(fid, '\\centering\n');
        fprintf(fid, '\\begin{tabular}{%s}\n', col_spec);
        fprintf(fid, '\\hline\n');

        % Header row
        fprintf(fid, 'Problem & UB');
        for v = 1:num_variants
            fprintf(fid, ' & \\multicolumn{2}{c|}{%s}', results(1).variants(v).name);
        end
        fprintf(fid, ' \\\\ \\hline\n');

        % Sub-header
        fprintf(fid, ' & ');
        for v = 1:num_variants
            fprintf(fid, ' & Best & RPD(\\%%)');
        end
        fprintf(fid, ' \\\\ \\hline\n');

        % Data rows
        arpd = zeros(num_variants, 1);
        for i = 1:num_problems
            fprintf(fid, '%d & %d', i, results(i).ub);
            for v = 1:num_variants
                fv = results(i).variants(v).stats.vals(:, end);
                best_v = min(fv);
                rpd_v = 100 * (mean(fv) - results(i).ub) / results(i).ub;
                arpd(v) = arpd(v) + rpd_v;
                fprintf(fid, ' & %.0f & %.2f', best_v, rpd_v);
            end
            fprintf(fid, ' \\\\ \\hline\n');
        end

        % ARPD summary row
        arpd = arpd / num_problems;
        fprintf(fid, '\\multicolumn{2}{|c|}{ARPD}');
        for v = 1:num_variants
            fprintf(fid, ' & & %.2f', arpd(v));
        end
        fprintf(fid, ' \\\\ \\hline\n');

        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\\end{table}\n');
        clear cleanup;
    end

    % Cross-variant visualizations
    extra_plots = 0;
    if num_variants >= 2
        try
            plot_heat_matrix(results, fullfile(figures_dir, 'heat_matrix.png'));
            extra_plots = extra_plots + 1;
        catch e
            warning('generate_report:plotFailed', 'Heat matrix skipped: %s', e.message);
        end

        try
            plot_performance_profile(results, fullfile(figures_dir, 'performance_profile.png'));
            extra_plots = extra_plots + 1;
        catch e
            warning('generate_report:plotFailed', 'Performance profile skipped: %s', e.message);
        end

        try
            plot_violin_comparison(results, fullfile(figures_dir, 'violin_comparison.png'));
            extra_plots = extra_plots + 1;
        catch e
            warning('generate_report:plotFailed', 'Violin plot skipped: %s', e.message);
        end

        try
            plot_bump_chart(results, fullfile(figures_dir, 'bump_chart.png'));
            extra_plots = extra_plots + 1;
        catch e
            warning('generate_report:plotFailed', 'Bump chart skipped: %s', e.message);
        end

        % Ablation waterfall (useful when variants are cumulative additions)
        if num_variants >= 3
            try
                plot_ablation_waterfall(results, fullfile(figures_dir, 'ablation_waterfall.png'));
                extra_plots = extra_plots + 1;
            catch e
                warning('generate_report:plotFailed', 'Ablation waterfall skipped: %s', e.message);
            end
        end
    end

    % Population entropy curve (from problem 1 snapshots)
    if exist('pop_snaps', 'var') && ~isempty(pop_snaps)
        try
            plot_entropy_curve(pop_snaps, results(1).P, ...
                fullfile(figures_dir, 'entropy_curve.png'));
            extra_plots = extra_plots + 1;
        catch e
            warning('generate_report:plotFailed', 'Entropy curve skipped: %s', e.message);
        end

        % Animated frequency matrix
        try
            animate_frequency_matrix(pop_snaps, results(1).P, ...
                fullfile(figures_dir, 'frequency_animation.gif'));
            extra_plots = extra_plots + 1;
        catch e
            warning('generate_report:plotFailed', 'Frequency animation skipped: %s', e.message);
        end
    end

    % Animated convergence race (problem 1, multi-variant)
    if num_variants >= 2
        try
            animate_convergence_race(results, 1, ...
                fullfile(figures_dir, 'convergence_race.gif'));
            extra_plots = extra_plots + 1;
        catch e
            warning('generate_report:plotFailed', 'Convergence race skipped: %s', e.message);
        end
    end

    % Statistical significance tests
    if num_variants >= 2
        try
            generate_statistical_tables(results, tables_dir);
        catch e
            warning('generate_report:statsFailed', 'Statistical tables skipped: %s', e.message);
        end
    end

    fprintf('Report generated: %d tables, %d convergence plots', num_problems, num_problems);
    if num_variants >= 2
        fprintf(', 1 comparison table, statistical tests');
    end
    if extra_plots > 0
        fprintf(', %d analysis plots', extra_plots);
    end
    fprintf('\n');
end
