function test_data_loading()
% TEST_DATA_LOADING - Test that benchmark data loads correctly from JSON
%
% Verifies loaded data matches known values for all 10 Taillard problems

    fprintf('  Testing data loading...\n');

    %% Test 1: Load from JSON
    fprintf('    [1/4] Load from JSON...');
    problems = load_problems('data/taillard_20x5.json');
    assert(length(problems) == 10, 'Should load 10 problems');
    fprintf(' done\n');

    %% Test 2: Verify problem 1 dimensions and bounds
    fprintf('    [2/4] Problem 1 structure...');
    [M, N] = size(problems(1).P);
    assert(M == 5, sprintf('Expected 5 machines, got %d', M));
    assert(N == 20, sprintf('Expected 20 jobs, got %d', N));
    assert(problems(1).lb == 1232, sprintf('Expected lb=1232, got %d', problems(1).lb));
    assert(problems(1).ub == 1278, sprintf('Expected ub=1278, got %d', problems(1).ub));
    fprintf(' done\n');

    %% Test 3: Verify problem 1 data values (spot check)
    fprintf('    [3/4] Problem 1 data values...');
    % First row, first few elements: [54 83 15 71 77 ...]
    assert(problems(1).P(1,1) == 54, 'P(1,1) should be 54');
    assert(problems(1).P(1,2) == 83, 'P(1,2) should be 83');
    assert(problems(1).P(1,3) == 15, 'P(1,3) should be 15');
    % Last row, last element: 28
    assert(problems(1).P(5,20) == 28, 'P(5,20) should be 28');
    fprintf(' done\n');

    %% Test 4: Verify all bounds are populated
    fprintf('    [4/4] All problems have bounds...');
    expected_lbs = [1232, 1290, 1073, 1268, 1198, 1180, 1226, 1170, 1206, 1082];
    expected_ubs = [1278, 1359, 1081, 1293, 1235, 1195, 1234, 1206, 1230, 1108];
    for i = 1:10
        assert(problems(i).lb == expected_lbs(i), ...
            sprintf('Problem %d: expected lb=%d, got %d', i, expected_lbs(i), problems(i).lb));
        assert(problems(i).ub == expected_ubs(i), ...
            sprintf('Problem %d: expected ub=%d, got %d', i, expected_ubs(i), problems(i).ub));
    end
    fprintf(' done\n');

    fprintf('  All data loading tests passed!\n');
end
