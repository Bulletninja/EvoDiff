function test_data_loading()
% TEST_DATA_LOADING - Test that benchmark data loads correctly from JSON
%
% Verifies loaded data matches known values for all Taillard problem sets

    fprintf('  Testing data loading...\n');

    %% Test 1: Load 20x5 from JSON
    fprintf('    [1/7] Load 20x5 from JSON...');
    problems = load_problems('data/taillard_20x5.json');
    assert(length(problems) == 10, 'Should load 10 problems');
    fprintf(' done\n');

    %% Test 2: Verify 20x5 problem 1 dimensions and bounds
    fprintf('    [2/7] 20x5 problem 1 structure...');
    [M, N] = size(problems(1).P);
    assert(M == 5, sprintf('Expected 5 machines, got %d', M));
    assert(N == 20, sprintf('Expected 20 jobs, got %d', N));
    assert(problems(1).lb == 1232, sprintf('Expected lb=1232, got %d', problems(1).lb));
    assert(problems(1).ub == 1278, sprintf('Expected ub=1278, got %d', problems(1).ub));
    fprintf(' done\n');

    %% Test 3: Verify 20x5 problem 1 data values (spot check)
    fprintf('    [3/7] 20x5 problem 1 data values...');
    assert(problems(1).P(1,1) == 54, 'P(1,1) should be 54');
    assert(problems(1).P(1,2) == 83, 'P(1,2) should be 83');
    assert(problems(1).P(1,3) == 15, 'P(1,3) should be 15');
    assert(problems(1).P(5,20) == 28, 'P(5,20) should be 28');
    fprintf(' done\n');

    %% Test 4: Verify all 20x5 bounds
    fprintf('    [4/7] All 20x5 bounds...');
    expected_lbs = [1232, 1290, 1073, 1268, 1198, 1180, 1226, 1170, 1206, 1082];
    expected_ubs = [1278, 1359, 1081, 1293, 1235, 1195, 1234, 1206, 1230, 1108];
    for i = 1:10
        assert(problems(i).lb == expected_lbs(i), ...
            sprintf('Problem %d: expected lb=%d, got %d', i, expected_lbs(i), problems(i).lb));
        assert(problems(i).ub == expected_ubs(i), ...
            sprintf('Problem %d: expected ub=%d, got %d', i, expected_ubs(i), problems(i).ub));
    end
    fprintf(' done\n');

    %% Test 5: Load 20x10 from JSON
    fprintf('    [5/7] Load 20x10 (ta011-ta020)...');
    p10 = load_problems('data/taillard_20x10.json');
    assert(length(p10) == 10, 'Should load 10 problems');
    [M10, N10] = size(p10(1).P);
    assert(M10 == 10, sprintf('Expected 10 machines, got %d', M10));
    assert(N10 == 20, sprintf('Expected 20 jobs, got %d', N10));
    ubs_10 = [1582, 1659, 1496, 1377, 1419, 1397, 1484, 1538, 1593, 1591];
    for i = 1:10
        assert(p10(i).ub == ubs_10(i), ...
            sprintf('ta%03d: expected ub=%d, got %d', 10+i, ubs_10(i), p10(i).ub));
    end
    fprintf(' done\n');

    %% Test 6: Load 20x20 from JSON
    fprintf('    [6/7] Load 20x20 (ta021-ta030)...');
    p20 = load_problems('data/taillard_20x20.json');
    assert(length(p20) == 10, 'Should load 10 problems');
    [M20, N20] = size(p20(1).P);
    assert(M20 == 20, sprintf('Expected 20 machines, got %d', M20));
    assert(N20 == 20, sprintf('Expected 20 jobs, got %d', N20));
    ubs_20 = [2297, 2099, 2326, 2223, 2291, 2226, 2273, 2200, 2237, 2178];
    for i = 1:10
        assert(p20(i).ub == ubs_20(i), ...
            sprintf('ta%03d: expected ub=%d, got %d', 20+i, ubs_20(i), p20(i).ub));
    end
    fprintf(' done\n');

    %% Test 7: Cross-size consistency (same generator, different seeds)
    fprintf('    [7/7] Cross-size consistency...');
    % All processing times should be in [1, 99] range (Taillard's generator)
    for i = 1:10
        assert(all(p10(i).P(:) >= 1) && all(p10(i).P(:) <= 99), ...
            sprintf('ta%03d: values out of [1,99]', 10+i));
        assert(all(p20(i).P(:) >= 1) && all(p20(i).P(:) <= 99), ...
            sprintf('ta%03d: values out of [1,99]', 20+i));
    end
    fprintf(' done\n');

    fprintf('  All data loading tests passed!\n');
end
