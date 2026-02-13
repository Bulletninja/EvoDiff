function results = run_experiment(problems, config)
% RUN_EXPERIMENT Orchestrate multiple DE runs across problems and variants
%
% Runs the DE algorithm multiple times on each problem for each configured
% variant, collecting statistics for comparison.
%
% Args:
%   problems - Struct array from load_problems()
%   config   - Config struct from load_config() (must have .variants)
%
% Returns:
%   results  - Struct array with per-problem data:
%              .P, .lb, .ub       — problem data
%              .variants(v).name  — variant name
%              .variants(v).stats — stats struct (vals, errlb, errub, nfevals)
%              (no .stats/.stats_selective aliases — use .variants directly)

    % Seed RNG for reproducibility if configured
    if isfield(config, 'random_seed') && ~isempty(config.random_seed)
        rng(config.random_seed);
    end

    num_problems = length(problems);
    N = config.num_runs;
    max_gen = config.max_generations;
    NP = config.population_size;
    f = config.fitness_function;
    selection_ratio = config.selection_ratio;

    % Get variants from config
    variants = config.variants;
    num_variants = length(variants);
    total_runs = num_problems * num_variants * N;

    % Header
    [prob_M, prob_N] = size(problems(1).P);
    fprintf('\n');
    fprintf('  EvoDiff - Differential Evolution for Flow Shop\n');
    fprintf('  %d problems x %d variants x %d runs = %d total runs\n', ...
        num_problems, num_variants, N, total_runs);
    fprintf('  NP=%d, gen=%d, jobs=%dx%d\n', NP, max_gen, prob_N, prob_M);
    fprintf('\n');
    fflush(stdout);

    exp_tic = tic();

    % Initialize results
    for i = 1:num_problems
        results(i).P  = problems(i).P;
        results(i).lb = problems(i).lb;
        results(i).ub = problems(i).ub;

        for v = 1:num_variants
            results(i).variants(v).name = variants(v).name;
            results(i).variants(v).stats.vals    = zeros(N, max_gen);
            results(i).variants(v).stats.errlb   = zeros(N, 1);
            results(i).variants(v).stats.errub   = zeros(N, 1);
            results(i).variants(v).stats.nfevals = zeros(N, 1);
        end
    end

    completed_runs = 0;

    for j = 1:num_problems
        [pM, pN] = size(problems(j).P);
        fprintf('  Problem %d/%d (%dx%d, UB=%d)\n', j, num_problems, pN, pM, problems(j).ub);
        fflush(stdout);

        for v = 1:num_variants
            var = variants(v);
            % Extract selective flag from variant, fallback to false
            selective = false;
            if isfield(var, 'selective')
                selective = var.selective;
            end
            sel_ratio = selection_ratio;
            if isfield(var, 'selection_ratio')
                sel_ratio = var.selection_ratio;
            end

            var_tic = tic();
            var_best = Inf;

            % Pad variant name to 12 chars for alignment
            padded_name = var.name;
            if length(padded_name) < 12
                padded_name = [padded_name, repmat(' ', 1, 12 - length(padded_name))];
            end

            for i = 1:N
                % Live progress bar
                bar_len = 20;
                filled = round(bar_len * (i-1) / N);
                bar_str = [repmat('#', 1, filled), repmat('.', 1, bar_len - filled)];
                fprintf('\r    %-12s [%s] %d/%d  ', padded_name, bar_str, i-1, N);
                fflush(stdout);

                try
                    [~, run_fit, num_evals, difflb, diffub, best_per_gen] = ...
                        de_flowshop(problems(j), NP, max_gen, f, selective, sel_ratio, var);
                    results(j).variants(v).stats.vals(i,:)    = best_per_gen;
                    results(j).variants(v).stats.errlb(i)     = difflb;
                    results(j).variants(v).stats.errub(i)     = diffub;
                    results(j).variants(v).stats.nfevals(i)   = num_evals;
                    if run_fit < var_best
                        var_best = run_fit;
                    end
                catch err
                    % CR-108: log error and continue
                    warning('run_experiment:runFailed', ...
                        'Problem %d, variant %s, run %d failed: %s', ...
                        j, var.name, i, err.message);
                end
                completed_runs = completed_runs + 1;
            end

            % Final line for this variant
            var_elapsed = toc(var_tic);
            rpd = 100 * (var_best - problems(j).ub) / problems(j).ub;
            bar_str = repmat('#', 1, bar_len);
            fprintf('\r    %-12s [%s] %d/%d  best=%-5d RPD=%.2f%%  [%.1fs]\n', ...
                padded_name, bar_str, N, N, var_best, rpd, var_elapsed);
            fflush(stdout);
        end
        fprintf('\n');
        fflush(stdout);
    end

    % Summary
    total_elapsed = toc(exp_tic);
    fprintf('  Complete: %d runs in %.1fs (%.2fs/run)\n\n', ...
        total_runs, total_elapsed, total_elapsed / total_runs);
    fflush(stdout);

end
