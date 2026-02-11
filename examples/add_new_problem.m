% add_new_problem.m - How to define and solve a custom flow shop problem
%
% You can solve any flow shop problem by providing processing times.

setup_paths();

% Define a custom 3-machine, 6-job problem
% Each row is a machine, each column is a job
processing_times = [
    10  5  8 12  6  9;   % Machine 1
     7 11  4  8 13  5;   % Machine 2
     6  9 10  7  3 14    % Machine 3
];

% Create problem struct
prob.P = processing_times;
prob.lb = 0;   % Set to 0 if unknown
prob.ub = Inf; % Set to Inf if unknown

% Solve it
[best_ind, best_val, num_evals, ~, ~, best_per_gen] = ...
    de_flowshop(prob, 100, 30, 'evaluate_makespan', false);

fprintf('Custom problem solution:\n');
fprintf('  Best makespan: %d\n', best_val);
fprintf('  Job order: ');
[M, N] = size(prob.P);

% Extract job order from best individual
% Each column of best_ind matches a column of the original P
for j = 1:N
    for k = 1:N
        if isequal(best_ind(:,j), prob.P(:,k))
            fprintf('%d ', k);
            break;
        end
    end
end
fprintf('\n');

% To use your own data file, create a JSON with this structure:
% {
%   "problems": [{
%     "id": 1,
%     "machines": 3,
%     "jobs": 6,
%     "processing_times": [[10,5,8,12,6,9], [7,11,4,8,13,5], [6,9,10,7,3,14]],
%     "lower_bound": 0,
%     "upper_bound": 999
%   }]
% }
% Then load with: problems = load_problems('data/your_file.json');
