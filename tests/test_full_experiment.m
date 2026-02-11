function test_full_experiment()
% TEST_FULL_EXPERIMENT - Integration test for run_experiment()
%
% Runs a minimal experiment (1 problem, 2 runs, 10 generations)
% and verifies the output structure.

    fprintf('  Testing full experiment integration...\n');

    %% Test 1: Run experiment and check structure
    fprintf('    [1/2] Run experiment...');

    problems = load_problems('data/taillard_20x5.json');
    problems = problems(1);  % Only 1 problem

    config = load_config();
    config.num_runs = 2;
    config.max_generations = 10;
    config.population_size = 50;

    results = run_experiment(problems, config);

    assert(length(results) == 1, 'Should have 1 result');
    assert(isequal(size(results(1).stats.vals), [2, 10]), ...
        'Stats vals should be num_runs x max_generations');
    assert(length(results(1).stats.errlb) == 2, ...
        'Should have 2 error values');
    assert(all(results(1).stats.nfevals > 0), ...
        'All runs should have positive eval counts');
    fprintf(' done\n');

    %% Test 2: Selective stats also populated
    fprintf('    [2/2] Selective stats...');
    assert(isequal(size(results(1).stats_selective.vals), [2, 10]), ...
        'Selective stats should also be populated');
    assert(all(results(1).stats_selective.nfevals > 0), ...
        'Selective runs should have positive eval counts');
    fprintf(' done\n');

    fprintf('  All full experiment tests passed!\n');
end
