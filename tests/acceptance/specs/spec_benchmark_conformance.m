function [num_pass, num_fail, results] = spec_benchmark_conformance(ctx)
% SPEC_BENCHMARK_CONFORMANCE Layer 1: Taillard benchmark bounds
%
% Validates benchmark data integrity and optimizer performance against
% known bounds. No mention of load_problems, Prob.P, or internal fields.

    num_pass = 0;
    num_fail = 0;
    results = {};

    %% Assertion 1: Taillard benchmark has 10 problems
    name = 'Taillard benchmark has 10 problems';
    try
        problems = ctx.problems.taillard();
        ctx.verify.equals(length(problems), 10);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 2: Each problem is 5 machines x 20 jobs
    name = 'Each problem is 5 machines x 20 jobs';
    try
        for i = 1:length(problems)
            dims = ctx.problems.dimensions(problems(i));
            ctx.verify.equals(dims, [5, 20]);
        end
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 3: All problems have valid bounds (ub >= lb > 0)
    name = 'All problems have valid bounds';
    try
        for i = 1:length(problems)
            bounds = ctx.problems.bounds(problems(i));
            ctx.verify.is_true(bounds.lower > 0);
            ctx.verify.is_true(bounds.upper >= bounds.lower);
        end
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 4: Optimizer finds solutions within reasonable range on problem 1
    name = 'Optimizer finds solutions within reasonable range on problem 1';
    try
        problem1 = ctx.problems.taillard_instance(1);
        bounds1 = ctx.problems.bounds(problem1);
        opts = struct('population_size', 50, 'max_generations', 20);
        result = ctx.solver.optimize(problem1, opts);
        ctx.verify.is_true(result.best_makespan <= 2 * bounds1.upper);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 5: Benchmark result is independently verifiable
    name = 'Benchmark result is independently verifiable';
    try
        recalculated = ctx.solver.evaluate_schedule(result.best_schedule);
        ctx.verify.equals(result.best_makespan, recalculated);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

end
