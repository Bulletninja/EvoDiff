% QuickTest - Fast validation run with plots
% 1 problem, 3 runs each (normal + selective)
% Shows convergence plot

config = load_config('config/quick_test.json');
FS = load_problems(config.problem_file);

fprintf('\n========================================\n');
fprintf('QUICK TEST: Problem 1, %d runs\n', config.num_runs);
fprintf('========================================\n');

% Seed control
if ~isempty(config.random_seed)
    rng(config.random_seed);
else
    rng('shuffle');
end

N = config.num_runs;
max_generations = config.max_generations;
NP = config.population_size;

j = 1;  % Only problem 1
fprintf('\nPROBLEM %d (lb=%d, ub=%d)\n', j, FS(j).lb, FS(j).ub);

% Store results for plotting
results_normal = zeros(N, max_generations);
results_selective = zeros(N, max_generations);
best_normal = zeros(N, 1);
best_selective = zeros(N, 1);

for i = 1:N
    fprintf('  Run %d/%d - Normal...', i, N);
    tic;
    [best_ind, best_val, num_evals, difflb, diffub, best_per_gen] = ...
        de_flowshop(FS(j), NP, max_generations, config.fitness_function, false, config.selection_ratio);
    elapsed = toc;
    fprintf(' %.1fs (best=%.0f, err_lb=%.1f%%)\n', elapsed, best_val, 100*difflb/FS(j).lb);
    results_normal(i,:) = best_per_gen;
    best_normal(i) = best_val;

    fprintf('  Run %d/%d - Selective...', i, N);
    tic;
    [best_ind, best_val, num_evals, difflb, diffub, best_per_gen] = ...
        de_flowshop(FS(j), NP, max_generations, config.fitness_function, true, config.selection_ratio);
    elapsed = toc;
    fprintf(' %.1fs (best=%.0f, err_lb=%.1f%%)\n', elapsed, best_val, 100*difflb/FS(j).lb);
    results_selective(i,:) = best_per_gen;
    best_selective(i) = best_val;
end

fprintf('\nQuick test completed!\n');

% Summary
fprintf('\n--- Summary ---\n');
fprintf('Normal:    best=%.0f, mean=%.0f\n', min(best_normal), mean(best_normal));
fprintf('Selective: best=%.0f, mean=%.0f\n', min(best_selective), mean(best_selective));
fprintf('Lower bound: %d\n', FS(j).lb);

% Plot convergence
figure('Name', 'QuickTest Convergence');

x_range = 1:max_generations;

subplot(1,2,1);
hold on;
for i = 1:N
    plot(results_normal(i,:), 'b-', 'LineWidth', 1);
end
plot(x_range, ones(1,max_generations)*FS(j).lb, 'g--', 'LineWidth', 2);
plot(x_range, ones(1,max_generations)*FS(j).ub, 'r--', 'LineWidth', 1);
hold off;
title('Normal DE');
xlabel('Generation');
ylabel('Best Makespan');
grid on;

subplot(1,2,2);
hold on;
for i = 1:N
    plot(results_selective(i,:), 'm-', 'LineWidth', 1);
end
plot(x_range, ones(1,max_generations)*FS(j).lb, 'g--', 'LineWidth', 2);
plot(x_range, ones(1,max_generations)*FS(j).ub, 'r--', 'LineWidth', 1);
hold off;
title('Selective DE');
xlabel('Generation');
ylabel('Best Makespan');
grid on;

% Save plot
if config.save_results
    results_fig_dir = fullfile(config.results_dir, 'figures');
    if ~exist(results_fig_dir, 'dir'), mkdir(results_fig_dir); end
    saveas(gcf, fullfile(results_fig_dir, 'QuickTest_convergence.png'));
    fprintf('\nPlot saved to: %s\n', fullfile(results_fig_dir, 'QuickTest_convergence.png'));
end
