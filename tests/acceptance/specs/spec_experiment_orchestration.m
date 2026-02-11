function [num_pass, num_fail, results] = spec_experiment_orchestration(ctx)
% SPEC_EXPERIMENT_ORCHESTRATION Layer 1: multi-run experiments
%
% Validates experiment orchestration through domain-level assertions.
% No mention of run_experiment, de_flowshop, or internal struct layout.

    num_pass = 0;
    num_fail = 0;
    results = {};

    % Shared setup: 1 problem, minimal config for speed
    all_problems = ctx.problems.taillard();
    problems = all_problems(1);
    config = ctx.config.quick_test();
    config.num_runs = 2;
    config.max_generations = 10;
    config.population_size = 30;

    exp_results = ctx.experiment.run(problems, config);

    %% Assertion 1: Experiment produces results for each problem
    name = 'Experiment produces results for each problem';
    try
        ctx.verify.equals(length(exp_results), 1);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 2: Results contain convergence data for every run
    name = 'Results contain convergence data for every run';
    try
        ctx.verify.has_field(exp_results(1), 'stats');
        ctx.verify.has_size(exp_results(1).stats.vals, [2, 10]);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 3: Each run records evaluation counts
    name = 'Each run records evaluation counts';
    try
        ctx.verify.equals(length(exp_results(1).stats.nfevals), 2);
        ctx.verify.is_true(all(exp_results(1).stats.nfevals > 0));
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 4: Both normal and selective modes are compared
    name = 'Both normal and selective modes are compared';
    try
        ctx.verify.has_field(exp_results(1), 'stats_selective');
        ctx.verify.has_size(exp_results(1).stats_selective.vals, [2, 10]);
        ctx.verify.is_true(all(exp_results(1).stats_selective.nfevals > 0));
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

end
