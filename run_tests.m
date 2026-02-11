function results = run_tests(varargin)
% RUN_TESTS - Run all tests in the tests/ directory
%
% Usage:
%   run_tests()              - Run all tests
%   run_tests('verbose')     - Run with detailed output
%   run_tests('pattern', 'test_makespan') - Run specific test
%
% Returns:
%   results - Structure with pass/fail counts

    verbose = any(strcmp(varargin, 'verbose'));
    pattern = '';
    for i = 1:length(varargin)-1
        if strcmp(varargin{i}, 'pattern')
            pattern = varargin{i+1};
        end
    end

    % Ensure paths are set up
    setup_paths();

    % Find all test files
    test_files = dir('tests/test_*.m');

    if ~isempty(pattern)
        mask = false(length(test_files), 1);
        for k = 1:length(test_files)
            mask(k) = ~isempty(strfind(test_files(k).name, pattern));
        end
        test_files = test_files(mask);
    end

    total_tests = 0;
    passed = 0;
    failed = 0;
    failed_tests = {};
    total_elapsed = 0;

    fprintf('\n========================================\n');
    fprintf('Running EvoDiff Test Suite\n');
    fprintf('========================================\n\n');

    for i = 1:length(test_files)
        test_name = test_files(i).name(1:end-2);
        fprintf('Running %s...', test_name);

        tic;
        try
            feval(test_name);
            elapsed = toc;
            passed = passed + 1;
            fprintf('  PASSED (%.2fs)\n\n', elapsed);
        catch ME
            elapsed = toc;
            failed = failed + 1;
            failed_tests{end+1} = test_name;
            fprintf('  FAILED: %s (%.2fs)\n', ME.message, elapsed);
            if verbose
                fprintf('  Stack trace:\n');
                for j = 1:length(ME.stack)
                    fprintf('    %s (line %d)\n', ME.stack(j).name, ME.stack(j).line);
                end
            end
            fprintf('\n');
        end

        total_tests = total_tests + 1;
        total_elapsed = total_elapsed + elapsed;
    end

    fprintf('========================================\n');
    fprintf('Test Results:\n');
    fprintf('  Total:  %d\n', total_tests);
    fprintf('  Passed: %d\n', passed);
    fprintf('  Failed: %d\n', failed);
    fprintf('  Time:   %.2fs\n', total_elapsed);

    if failed > 0
        fprintf('\nFailed tests:\n');
        for i = 1:length(failed_tests)
            fprintf('  - %s\n', failed_tests{i});
        end
    end

    fprintf('========================================\n\n');

    results.total = total_tests;
    results.passed = passed;
    results.failed = failed;
    results.failed_tests = failed_tests;
    results.success = (failed == 0);
    results.elapsed = total_elapsed;

    if failed > 0
        fprintf('TESTS FAILED\n\n');
    else
        fprintf('ALL TESTS PASSED\n\n');
    end
end
