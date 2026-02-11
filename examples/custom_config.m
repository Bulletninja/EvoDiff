% custom_config.m - Running EvoDiff with custom parameters
%
% Shows how to modify configuration without editing source code.

setup_paths();

% Load and customize config
config = load_config('config/default.json');
config.population_size = 300;
config.max_generations = 50;
config.num_runs = 5;
config.random_seed = 123;  % Set seed for reproducibility

% Set seed
rng(config.random_seed);

% Load problems
problems = load_problems(config.problem_file);

% Run on first 3 problems
for i = 1:3
    fprintf('\nProblem %d (lb=%d, ub=%d):\n', i, problems(i).lb, problems(i).ub);

    best_vals = zeros(config.num_runs, 1);
    for r = 1:config.num_runs
        [~, best_val, ~, ~, ~, ~] = ...
            de_flowshop(problems(i), config.population_size, ...
                config.max_generations, config.fitness_function, false);
        best_vals(r) = best_val;
    end

    fprintf('  Best:   %.0f\n', min(best_vals));
    fprintf('  Mean:   %.1f\n', mean(best_vals));
    fprintf('  Median: %.1f\n', median(best_vals));
end
