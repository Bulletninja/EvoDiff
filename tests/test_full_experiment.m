function test_full_experiment()
% TEST_FULL_EXPERIMENT - Integration test for run_experiment()
%
% Runs a minimal experiment (1 problem, 2 runs, 10 generations)
% and verifies the variant-based output structure.

    fprintf('  Testing full experiment integration...\n');

    %% Test 1: Run experiment and check variant structure
    fprintf('    [1/3] Run experiment...');

    problems = load_problems('data/taillard_20x5.json');
    problems = problems(1);  % Only 1 problem

    config = load_config();
    config.num_runs = 2;
    config.max_generations = 10;
    config.population_size = 50;

    results = run_experiment(problems, config);

    assert(length(results) == 1, 'Should have 1 result');
    assert(isfield(results(1), 'variants'), 'Results should have variants field');
    num_variants = length(results(1).variants);
    assert(num_variants >= 2, 'Should have at least 2 variants');
    fprintf(' done\n');

    %% Test 2: Each variant has correct stats dimensions
    fprintf('    [2/3] Variant stats...');
    for v = 1:num_variants
        assert(isequal(size(results(1).variants(v).stats.vals), [2, 10]), ...
            sprintf('Variant %d: vals should be num_runs x max_generations', v));
        assert(length(results(1).variants(v).stats.errlb) == 2, ...
            sprintf('Variant %d: should have 2 error values', v));
        assert(all(results(1).variants(v).stats.nfevals > 0), ...
            sprintf('Variant %d: all runs should have positive eval counts', v));
    end
    fprintf(' done\n');

    %% Test 3: Variant names match config
    fprintf('    [3/3] Variant names...');
    assert(strcmp(results(1).variants(1).name, config.variants(1).name), ...
        'First variant name should match config');
    assert(strcmp(results(1).variants(2).name, config.variants(2).name), ...
        'Second variant name should match config');
    fprintf(' done\n');

    fprintf('  All full experiment tests passed!\n');
end
