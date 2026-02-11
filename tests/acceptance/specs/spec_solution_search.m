function [num_pass, num_fail, results] = spec_solution_search(ctx)
% SPEC_SOLUTION_SEARCH Layer 1: optimizer behavior
%
% Validates optimizer through domain-level assertions.
% No mention of de_flowshop, random_permutation, or Prob struct fields.

    num_pass = 0;
    num_fail = 0;
    results = {};

    % Shared setup: small problem, fast optimizer settings
    problem = ctx.problems.small_instance(3, 5, 42);
    opts = struct('population_size', 30, 'max_generations', 10);

    %% Assertion 1: Optimizer produces a valid schedule (valid permutation)
    name = 'Optimizer produces a valid schedule';
    try
        result = ctx.solver.optimize(problem, opts);
        ctx.verify.is_valid_schedule(result.best_schedule, problem);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 2: Solution quality never degrades over generations
    name = 'Solution quality never degrades over generations';
    try
        ctx.verify.improves_over_time(result.best_per_generation);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 3: Reported best matches independent re-evaluation
    name = 'Reported best matches independent re-evaluation';
    try
        reported = result.best_makespan;
        recalculated = ctx.solver.evaluate_schedule(result.best_schedule);
        ctx.verify.equals(reported, recalculated);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 4: Selective breeding mode also works
    name = 'Selective breeding mode also works';
    try
        problem2 = ctx.problems.small_instance(3, 5, 42);
        opts_sel = struct('population_size', 30, 'max_generations', 10, 'selective', true);
        result_sel = ctx.solver.optimize(problem2, opts_sel);
        ctx.verify.is_valid_schedule(result_sel.best_schedule, problem2);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 5: Random schedules are valid permutations
    name = 'Random schedules are valid permutations';
    try
        problem3 = ctx.problems.small_instance(3, 5, 99);
        schedule = ctx.solver.create_random_schedule(problem3);
        ctx.verify.is_valid_schedule(schedule, problem3);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 6: Random schedule generation produces diversity
    name = 'Random schedule generation produces diversity';
    try
        problem4 = ctx.problems.small_instance(3, 5, 77);
        s1 = ctx.solver.create_random_schedule(problem4);
        s2 = ctx.solver.create_random_schedule(problem4);
        s3 = ctx.solver.create_random_schedule(problem4);
        all_same = isequal(s1, s2) && isequal(s2, s3);
        ctx.verify.is_true(~all_same);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

end
