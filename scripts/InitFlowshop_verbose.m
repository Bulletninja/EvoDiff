% InitFlowshop_verbose - Verbose benchmark runner with checkpoint support
%
% CHECKPOINT SUPPORT: Saves after each problem, auto-resumes if interrupted
%   - Checkpoints saved to results/checkpoint_problem_XX.mat
%   - To start fresh: delete files in results/ directory

config = load_config('config/default.json');

RESULTS_DIR = config.results_dir;
CHECKPOINT_PREFIX = 'checkpoint_problem_';
if ~exist(RESULTS_DIR, 'dir'), mkdir(RESULTS_DIR); end

% Load benchmark data
FS = load_problems(config.problem_file);
num_problems = length(FS);

% Seed control
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

% Check for existing checkpoint to resume
start_problem = 1;
checkpoint_files = dir(fullfile(RESULTS_DIR, [CHECKPOINT_PREFIX '*.mat']));
if ~isempty(checkpoint_files)
    problem_nums = zeros(length(checkpoint_files), 1);
    for k = 1:length(checkpoint_files)
        tokens = regexp(checkpoint_files(k).name, [CHECKPOINT_PREFIX '(\d+)'], 'tokens');
        if ~isempty(tokens), problem_nums(k) = str2double(tokens{1}{1}); end
    end
    [last_problem, idx] = max(problem_nums);

    if last_problem > 0 && last_problem < num_problems
        fprintf('\n========================================\n');
        fprintf('CHECKPOINT FOUND! Resuming...\n');
        fprintf('========================================\n');
        checkpoint = load(fullfile(RESULTS_DIR, checkpoint_files(idx).name));
        FS = checkpoint.FS;
        start_problem = last_problem + 1;
        fprintf('  Last completed: problem %d\n', last_problem);
        fprintf('  Resuming from: problem %d\n', start_problem);
        fprintf('========================================\n');
    end
end

for j = start_problem:num_problems
    fprintf('\n========================================\n');
    fprintf('PROBLEM %d/%d (lb=%d, ub=%d)\n', j, num_problems, FS(j).lb, FS(j).ub);
    fprintf('========================================\n');

    for i = 1:N
        fprintf('  Run %2d/%d - Normal...', i, N);
        tic;
        [best_ind, best_val, num_evals, difflb, diffub, best_per_gen] = ...
            de_flowshop(FS(j), NP, max_generations, config.fitness_function, false);
        elapsed = toc;
        FS(j).stats.errlb(i)   = difflb;
        FS(j).stats.errub(i)   = diffub;
        FS(j).stats.vals(i,:)  = best_per_gen;
        FS(j).stats.nfevals(i) = num_evals;
        fprintf(' %.1fs (best=%.0f, err_lb=%.1f%%)\n', elapsed, best_val, 100*difflb/FS(j).lb);

        fprintf('  Run %2d/%d - Selective...', i, N);
        tic;
        [best_ind, best_val, num_evals, difflb, diffub, best_per_gen] = ...
            de_flowshop(FS(j), NP, max_generations, config.fitness_function, true);
        elapsed = toc;
        FS(j).stats_selective.errlb(i)   = difflb;
        FS(j).stats_selective.errub(i)   = diffub;
        FS(j).stats_selective.vals(i,:)  = best_per_gen;
        FS(j).stats_selective.nfevals(i) = num_evals;
        fprintf(' %.1fs (best=%.0f, err_lb=%.1f%%)\n', elapsed, best_val, 100*difflb/FS(j).lb);
    end

    % Save checkpoint after each problem
    checkpoint_file = fullfile(RESULTS_DIR, sprintf('%s%02d.mat', CHECKPOINT_PREFIX, j));
    checkpoint = struct('FS', FS, 'last_completed_problem', j, 'timestamp', datestr(now));
    save(checkpoint_file, '-struct', 'checkpoint');
    fprintf('  [CHECKPOINT] Saved: problem %d/%d\n', j, num_problems);

    figure;
    boxplot(FS(j).stats.vals, 1, '.', 1, 1);
    hold on;
    boxplot(FS(j).stats_selective.vals, 1, ['x','*'], 1, 1);
end
