function test_makespan()
% TEST_MAKESPAN - Unit tests for Makespan calculation
%
% Tests:
%   1. Input is not mutated (Bug #2 fix validation)
%   2. Known result for 2x3 problem
%   3. Single job case
%   4. Single machine case
%   5. Symmetry and correctness properties

    fprintf('  Testing Makespan calculation...\n');

    %% Test 1: Input not mutated (Critical bug fix)
    fprintf('    [1/5] Input mutation test...');
    P = [10 20 30; 15 25 35];
    P_original = P;
    makespan = Makespan(P);
    assert(isequal(P, P_original), ...
        'Input matrix should not be modified (Bug #2)');
    fprintf(' ✓\n');

    %% Test 2: Known result for 2 machines, 3 jobs
    fprintf('    [2/5] Known result test...');
    % Job order: 1, 2, 3
    % Machine 1: Job1=10 (finish 10), Job2=20 (finish 30), Job3=30 (finish 60)
    % Machine 2: Job1=15 (start 10, finish 25), Job2=25 (start 30, finish 55),
    %            Job3=35 (start 60, finish 95)
    % Expected makespan: 95
    expected = 95;
    actual = Makespan(P);
    assert(actual == expected, ...
        sprintf('Expected makespan=%d, got %d', expected, actual));
    fprintf(' ✓\n');

    %% Test 3: Single job (all operations sequential)
    fprintf('    [3/5] Single job test...');
    P_single = [10; 20; 30];
    expected_single = 60;  % Sum of all operations
    actual_single = Makespan(P_single);
    assert(actual_single == expected_single, ...
        sprintf('Single job: expected %d, got %d', expected_single, actual_single));
    fprintf(' ✓\n');

    %% Test 4: Single machine (all jobs sequential)
    fprintf('    [4/5] Single machine test...');
    P_machine = [10 20 30];
    expected_machine = 60;  % Sum of all jobs
    actual_machine = Makespan(P_machine);
    assert(actual_machine == expected_machine, ...
        sprintf('Single machine: expected %d, got %d', expected_machine, actual_machine));
    fprintf(' ✓\n');

    %% Test 5: Makespan is at least max of row sums and column sums
    fprintf('    [5/5] Lower bound test...');
    P_test = [5 10 15; 8 12 20; 6 9 18];
    makespan_test = Makespan(P_test);
    max_machine_load = max(sum(P_test, 2));  % Max row sum
    max_job_time = max(sum(P_test, 1));      % Max column sum
    lower_bound = max(max_machine_load, max_job_time);
    assert(makespan_test >= lower_bound, ...
        sprintf('Makespan (%d) should be >= lower bound (%d)', ...
        makespan_test, lower_bound));
    fprintf(' ✓\n');

    fprintf('  All Makespan tests passed!\n');
end
