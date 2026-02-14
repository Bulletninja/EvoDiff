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

    % Verification helpers (shared)
    h = verify_helpers();
    driver.verify_equals = h.verify_equals;
    driver.verify_within_bounds = h.verify_within_bounds;
    driver.verify_improves_over_time = h.verify_improves_over_time;
    driver.verify_is_valid_schedule = h.verify_is_valid_schedule;
    driver.verify_less_than = h.verify_less_than;
    driver.verify_has_field = h.verify_has_field;
    driver.verify_has_size = h.verify_has_size;
    driver.verify_is_true = h.verify_is_true;
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
