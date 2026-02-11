function results = run_experiment(problems, config)
% RUN_EXPERIMENT Orchestrate multiple DE runs across problems
%
% Runs the DE algorithm multiple times on each problem, collecting
% statistics for both normal and selective modes.
%
% Args:
%   problems - Struct array from load_problems()
%   config   - Config struct from load_config()
%
% Returns:
%   results  - Struct array with .stats and .stats_selective per problem

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

    % Initialize results
    for i = 1:num_problems
        results(i).P  = problems(i).P;
        results(i).lb = problems(i).lb;
        results(i).ub = problems(i).ub;

        results(i).stats.vals    = zeros(N, max_gen);
        results(i).stats.errlb   = zeros(N, 1);
        results(i).stats.errub   = zeros(N, 1);
        results(i).stats.nfevals = zeros(N, 1);

        results(i).stats_selective.vals    = zeros(N, max_gen);
        results(i).stats_selective.errlb   = zeros(N, 1);
        results(i).stats_selective.errub   = zeros(N, 1);
        results(i).stats_selective.nfevals = zeros(N, 1);
    end

    for j = 1:num_problems
        for i = 1:N
            try
                % Normal mode
                [~, ~, num_evals, difflb, diffub, best_per_gen] = ...
                    de_flowshop(problems(j), NP, max_gen, f, false, selection_ratio);
                results(j).stats.vals(i,:)    = best_per_gen;
                results(j).stats.errlb(i)     = difflb;
                results(j).stats.errub(i)     = diffub;
                results(j).stats.nfevals(i)   = num_evals;

                % Selective mode
                [~, ~, num_evals, difflb, diffub, best_per_gen] = ...
                    de_flowshop(problems(j), NP, max_gen, f, true, selection_ratio);
                results(j).stats_selective.vals(i,:)    = best_per_gen;
                results(j).stats_selective.errlb(i)     = difflb;
                results(j).stats_selective.errub(i)     = diffub;
                results(j).stats_selective.nfevals(i)   = num_evals;
            catch err
                % CR-108: log error and continue — don't lose all progress
                warning('run_experiment:runFailed', ...
                    'Problem %d, run %d failed: %s', j, i, err.message);
            end
        end
    end
end
