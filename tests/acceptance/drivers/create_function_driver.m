function driver = create_function_driver()
% CREATE_FUNCTION_DRIVER Layer 3 driver: direct function calls (reference)
%
% Returns a struct of function handles that map domain actions to
% production function calls. This is the ONLY file that knows
% de_flowshop()'s signature, evaluate_makespan()'s name,
% Prob.P/.lb/.ub struct fields, etc.

    % Solver actions
    driver.optimize = @do_optimize;
    driver.evaluate_schedule = @(schedule) evaluate_makespan(schedule);
    driver.create_random_schedule = @do_create_random_schedule;

    % Problem loading
    driver.load_taillard = @() load_problems('data/taillard_20x5.json');
    driver.load_taillard_instance = @do_load_taillard_instance;
    driver.small_instance = @do_small_instance;
    driver.problem_dimensions = @(problem) size(problem.P);
    driver.problem_bounds = @(problem) struct('lower', problem.lb, 'upper', problem.ub);

    % Configuration
    driver.load_defaults = @() load_config();
    driver.load_config_file = @(path) load_config(path);
    driver.load_quick_test = @() load_config('config/quick_test.json');

    % Experiment
    driver.run_experiment = @(problems, config) run_experiment(problems, config);

    % Verification helpers
    driver.verify_equals = @verify_equals_impl;
    driver.verify_within_bounds = @verify_within_bounds_impl;
    driver.verify_improves_over_time = @verify_improves_over_time_impl;
    driver.verify_is_valid_schedule = @verify_is_valid_schedule_impl;
    driver.verify_less_than = @verify_less_than_impl;
    driver.verify_has_field = @verify_has_field_impl;
    driver.verify_has_size = @verify_has_size_impl;
    driver.verify_is_true = @verify_is_true_impl;
end


%% Domain action implementations

function result = do_optimize(problem, opts)
    NP = opts.population_size;
    max_gen = opts.max_generations;
    selective = false;
    if isfield(opts, 'selective')
        selective = opts.selective;
    end
    selection_ratio = 0.5;
    if isfield(opts, 'selection_ratio')
        selection_ratio = opts.selection_ratio;
    end
    [best_ind, best_fit, num_evals, difflb, diffub, best_per_gen] = ...
        de_flowshop(problem, NP, max_gen, 'evaluate_makespan', selective, selection_ratio);
    result.best_schedule = best_ind;
    result.best_makespan = best_fit;
    result.num_evaluations = num_evals;
    result.diff_lower_bound = difflb;
    result.diff_upper_bound = diffub;
    result.best_per_generation = best_per_gen;
end

function schedule = do_create_random_schedule(problem)
    flat = random_permutation(problem.P);
    [M, N] = size(problem.P);
    schedule = reshape(flat, M, N);
end

function problem = do_load_taillard_instance(n)
    problems = load_problems('data/taillard_20x5.json');
    problem = problems(n);
end

function problem = do_small_instance(M, N, seed)
    % Deterministic problem from seed — does not touch random state
    values = zeros(M, N);
    for i = 1:M
        for j = 1:N
            values(i, j) = mod(seed * 7 + i * 13 + j * 17, 50) + 1;
        end
    end
    problem.P = values;
    problem.lb = max(max(sum(values, 2)), max(sum(values, 1)));
    problem.ub = sum(values(:));
end


%% Verification helpers

function verify_equals_impl(actual, expected)
    assert(isequal(actual, expected), ...
        sprintf('Expected %s, got %s', mat2str(expected), mat2str(actual)));
end

function verify_within_bounds_impl(value, lo, hi)
    assert(value >= lo && value <= hi, ...
        sprintf('Value %g not in [%g, %g]', value, lo, hi));
end

function verify_improves_over_time_impl(values)
    if length(values) > 1
        diffs = diff(values);
        assert(all(diffs <= 0), ...
            sprintf('Values should be monotonically non-increasing, max increase: %g', max(diffs)));
    end
end

function verify_is_valid_schedule_impl(schedule, problem)
    [M, N] = size(problem.P);
    assert(isequal(size(schedule), [M, N]), ...
        sprintf('Schedule should be %dx%d, got %dx%d', M, N, size(schedule, 1), size(schedule, 2)));
    orig_sorted = sortrows(problem.P')';
    sched_sorted = sortrows(schedule')';
    assert(isequal(orig_sorted, sched_sorted), ...
        'Schedule columns should be a permutation of the original jobs');
end

function verify_less_than_impl(a, b)
    assert(a < b, sprintf('Expected %g < %g', a, b));
end

function verify_has_field_impl(s, field_name)
    assert(isfield(s, field_name), ...
        sprintf('Struct missing field: %s', field_name));
end

function verify_has_size_impl(x, expected_size)
    assert(isequal(size(x), expected_size), ...
        sprintf('Expected size [%s], got [%s]', ...
        num2str(expected_size), num2str(size(x))));
end

function verify_is_true_impl(condition)
    assert(condition, 'Expected condition to be true');
end
