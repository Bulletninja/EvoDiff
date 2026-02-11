% quick_start.m - Minimal working example of EvoDiff
%
% Run this after setup_paths() to see the algorithm in action.

setup_paths();

% Load benchmark problems
problems = load_problems('data/taillard_20x5.json');

% Solve problem 1 with default settings
prob = problems(1);
fprintf('Solving Taillard problem 1 (lb=%d, ub=%d)...\n', prob.lb, prob.ub);

[best_ind, best_val, num_evals, difflb, diffub, best_per_gen] = ...
    de_flowshop(prob, 200, 50, 'evaluate_makespan', false);

fprintf('Best makespan found: %d\n', best_val);
fprintf('Distance from lower bound: %d\n', difflb);
fprintf('Function evaluations: %d\n', num_evals);

% Plot convergence
figure;
plot(best_per_gen, 'b-', 'LineWidth', 2);
hold on;
yline(prob.lb, 'g--', 'Lower Bound');
yline(prob.ub, 'r--', 'Upper Bound');
hold off;
xlabel('Generation');
ylabel('Best Makespan');
title('EvoDiff Convergence');
grid on;
