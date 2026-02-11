function test_makespan()
% TEST_MAKESPAN - Unit tests for evaluate_makespan calculation
%
% Tests:
%   1. Input is not mutated
%   2. Known result for 2x3 problem
%   3. Single job case
%   4. Single machine case
%   5. Lower bound property

    fprintf('  Testing evaluate_makespan...\n');

    %% Test 1: Input not mutated
    fprintf('    [1/5] Input mutation test...');
    P = [10 20 30; 15 25 35];
    P_original = P;
    makespan = evaluate_makespan(P);
    assert(isequal(P, P_original), ...
        'Input matrix should not be modified');
    fprintf(' done\n');

    %% Test 2: Known result for 2 machines, 3 jobs
    fprintf('    [2/5] Known result test...');
    expected = 95;
    actual = evaluate_makespan(P);
    assert(actual == expected, ...
        sprintf('Expected makespan=%d, got %d', expected, actual));
    fprintf(' done\n');

    %% Test 3: Single job (all operations sequential)
    fprintf('    [3/5] Single job test...');
    P_single = [10; 20; 30];
    expected_single = 60;
    actual_single = evaluate_makespan(P_single);
    assert(actual_single == expected_single, ...
        sprintf('Single job: expected %d, got %d', expected_single, actual_single));
    fprintf(' done\n');

    %% Test 4: Single machine (all jobs sequential)
    fprintf('    [4/5] Single machine test...');
    P_machine = [10 20 30];
    expected_machine = 60;
    actual_machine = evaluate_makespan(P_machine);
    assert(actual_machine == expected_machine, ...
        sprintf('Single machine: expected %d, got %d', expected_machine, actual_machine));
    fprintf(' done\n');

    %% Test 5: Makespan >= max of row sums and column sums
    fprintf('    [5/5] Lower bound test...');
    P_test = [5 10 15; 8 12 20; 6 9 18];
    makespan_test = evaluate_makespan(P_test);
    max_machine_load = max(sum(P_test, 2));
    max_job_time = max(sum(P_test, 1));
    lower_bound = max(max_machine_load, max_job_time);
    assert(makespan_test >= lower_bound, ...
        sprintf('Makespan (%d) should be >= lower bound (%d)', ...
        makespan_test, lower_bound));
    fprintf(' done\n');

    fprintf('  All evaluate_makespan tests passed!\n');
end
