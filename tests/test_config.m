function test_config()
% TEST_CONFIG - Test configuration loading and validation

    fprintf('  Testing configuration system...\n');

    %% Test 1: Load defaults (no file)
    fprintf('    [1/4] Default config...');
    config = load_config();
    assert(config.population_size == 500, 'Default population_size should be 500');
    assert(config.max_generations == 100, 'Default max_generations should be 100');
    assert(config.num_runs == 30, 'Default num_runs should be 30');
    assert(config.selective == false, 'Default selective should be false');
    assert(isempty(config.random_seed), 'Default random_seed should be empty');
    assert(strcmp(config.fitness_function, 'evaluate_makespan'), ...
        'Default fitness_function should be evaluate_makespan');
    fprintf(' done\n');

    %% Test 2: Load from file
    fprintf('    [2/4] Load from JSON...');
    config = load_config('config/quick_test.json');
    assert(config.population_size == 100, 'quick_test population_size should be 100');
    assert(config.max_generations == 20, 'quick_test max_generations should be 20');
    assert(config.num_runs == 3, 'quick_test num_runs should be 3');
    fprintf(' done\n');

    %% Test 3: Missing fields use defaults
    fprintf('    [3/4] Default merging...');
    assert(config.selection_ratio == 0.5, 'Missing fields should use defaults');
    fprintf(' done\n');

    %% Test 4: Missing file throws error
    fprintf('    [4/4] Missing file error...');
    threw_error = false;
    try
        load_config('nonexistent_file.json');
    catch
        threw_error = true;
    end
    assert(threw_error, 'Should throw error for missing file');
    fprintf(' done\n');

    fprintf('  All config tests passed!\n');
end
