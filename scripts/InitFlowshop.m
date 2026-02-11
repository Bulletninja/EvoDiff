% InitFlowshop - Main benchmark runner for Taillard flow shop problems
%
% Uses config/default.json for parameters. Override by editing the config
% or passing a different config file path to load_config().

config = load_config('config/default.json');

% Load benchmark data
FS = load_problems(config.problem_file);
num_problems = length(FS);

% Seed control for reproducibility
if ~isempty(config.random_seed)
    rng(config.random_seed);
else
    rng('shuffle');
end

N = config.num_runs;
max_generations = config.max_generations;
NP = config.population_size;

% Initialize stats storage
for i = 1:num_problems
    FS(i).stats.errslb  = zeros(N, max_generations);
    FS(i).stats.errsub  = zeros(N, max_generations);
    FS(i).stats.vals    = zeros(N, max_generations);
    FS(i).stats.nfevals = zeros(N, 1);

    FS(i).stats_selective.errslb  = zeros(N, max_generations);
    FS(i).stats_selective.errsub  = zeros(N, max_generations);
    FS(i).stats_selective.vals    = zeros(N, max_generations);
    FS(i).stats_selective.nfevals = zeros(N, 1);
end

% Main experiment loop
for j = 1:num_problems
    for i = 1:N
        [best_ind, best_val, num_evals, difflb, diffub, best_per_gen] = ...
            de_flowshop(FS(j), NP, max_generations, config.fitness_function, false, config.selection_ratio);
        FS(j).stats.errlb(i)   = difflb;
        FS(j).stats.errub(i)   = diffub;
        FS(j).stats.vals(i,:)  = best_per_gen;
        FS(j).stats.nfevals(i) = num_evals;

        [best_ind, best_val, num_evals, difflb, diffub, best_per_gen] = ...
            de_flowshop(FS(j), NP, max_generations, config.fitness_function, true, config.selection_ratio);
        FS(j).stats_selective.errlb(i)   = difflb;
        FS(j).stats_selective.errub(i)   = diffub;
        FS(j).stats_selective.vals(i,:)  = best_per_gen;
        FS(j).stats_selective.nfevals(i) = num_evals;
    end

    figure;
    boxplot(FS(j).stats.vals, 1, '.', 1, 1);
    hold on;
    boxplot(FS(j).stats_selective.vals, 1, ['x','*'], 1, 1);
end
