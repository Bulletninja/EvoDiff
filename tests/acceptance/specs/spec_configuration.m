function [num_pass, num_fail, results] = spec_configuration(ctx)
% SPEC_CONFIGURATION Layer 1: config loading and defaults
%
% Validates configuration loading through domain-level assertions.
% No mention of load_config, jsondecode, or internal file paths.

    num_pass = 0;
    num_fail = 0;
    results = {};

    %% Assertion 1: Default settings are suitable for full benchmark
    name = 'Default settings are suitable for full benchmark';
    try
        config = ctx.config.defaults();
        ctx.verify.equals(config.population_size, 500);
        ctx.verify.equals(config.max_generations, 100);
        ctx.verify.equals(config.num_runs, 30);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 2: Quick-test config uses smaller parameters
    name = 'Quick-test config uses smaller parameters';
    try
        config = ctx.config.defaults();
        quick = ctx.config.quick_test();
        ctx.verify.less_than(quick.population_size, config.population_size);
        ctx.verify.less_than(quick.max_generations, config.max_generations);
        ctx.verify.less_than(quick.num_runs, config.num_runs);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 3: Missing settings fall back to defaults
    name = 'Missing settings fall back to defaults';
    try
        quick = ctx.config.quick_test();
        ctx.verify.has_field(quick, 'selection_ratio');
        ctx.verify.equals(quick.selection_ratio, 0.5);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 4: Benchmark data loads from configured path
    name = 'Benchmark data loads from configured path';
    try
        problems = ctx.problems.taillard();
        ctx.verify.equals(length(problems), 10);
        dims = ctx.problems.dimensions(problems(1));
        ctx.verify.equals(dims, [5, 20]);
        bounds1 = ctx.problems.bounds(problems(1));
        ctx.verify.equals(bounds1.lower, 1232);
        ctx.verify.equals(bounds1.upper, 1278);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

end
