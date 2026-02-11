function [num_pass, num_fail, results] = spec_schedule_evaluation(ctx)
% SPEC_SCHEDULE_EVALUATION Layer 1: completion time behavior
%
% Validates schedule evaluation through domain-level assertions.
% No mention of evaluate_makespan, reshape, or struct field names.

    num_pass = 0;
    num_fail = 0;
    results = {};

    %% Assertion 1: A known 2-machine, 3-job schedule has completion time 95
    name = 'A known 2-machine, 3-job schedule has completion time 95';
    try
        schedule = [10 20 30; 15 25 35];
        completion_time = ctx.solver.evaluate_schedule(schedule);
        ctx.verify.equals(completion_time, 95);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 2: A single job takes the sum of its processing times
    name = 'A single job takes the sum of its processing times';
    try
        schedule = [10; 20; 30];
        completion_time = ctx.solver.evaluate_schedule(schedule);
        ctx.verify.equals(completion_time, 60);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 3: Jobs on one machine are processed sequentially
    name = 'Jobs on one machine are processed sequentially';
    try
        schedule = [10 20 30];
        completion_time = ctx.solver.evaluate_schedule(schedule);
        ctx.verify.equals(completion_time, 60);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

    %% Assertion 4: Completion time respects the theoretical lower bound
    name = 'Completion time respects the theoretical lower bound';
    try
        schedule = [5 10 15; 8 12 20; 6 9 18];
        completion_time = ctx.solver.evaluate_schedule(schedule);
        max_machine_load = max(sum(schedule, 2));
        max_job_time = max(sum(schedule, 1));
        lower_bound = max(max_machine_load, max_job_time);
        ctx.verify.is_true(completion_time >= lower_bound);
        num_pass = num_pass + 1;
        results{end+1} = struct('name', name, 'status', 'PASS');
    catch e
        num_fail = num_fail + 1;
        results{end+1} = struct('name', name, 'status', 'FAIL', 'message', e.message);
    end

end
