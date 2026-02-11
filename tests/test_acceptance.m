function test_acceptance()
% TEST_ACCEPTANCE Bridge: lets run_tests.m discover acceptance tests
%
% Runs all acceptance specs with the function driver and asserts all pass.

    fprintf('  Running acceptance tests (function driver)...\n');
    results = run_acceptance_tests('function');
    assert(results.success, ...
        sprintf('Acceptance tests failed: %d failures', results.failed));
    fprintf('  All acceptance tests passed! (%d assertions)\n', results.passed);
end
