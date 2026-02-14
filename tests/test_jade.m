function test_jade()
% TEST_JADE - Test JADE adaptive mutation
    fprintf('  Testing JADE adaptive mutation...\n');

    addpath(genpath('src'));
    problems = load_problems('data/taillard_20x5.json');
    prob = problems(1);

    jade_variant = struct( ...
        'name', 'jade', ...
        'selective', false, ...
        'selection_ratio', 0.5, ...
        'init_method', 'neh', ...
        'crossover', 'ox1', ...
        'local_search', true, ...
        'local_search_interval', 10, ...
        'population_reduction', true, ...
        'jade', true, ...
        'jade_c', 0.1, ...
        'jade_p', 0.1);

    %% Test 1: JADE produces valid solution
    fprintf('    [1/4] Valid solution...');
    [best_ind, best_fit, ne] = de_flowshop(prob, 30, 10, 'evaluate_makespan', false, 0.5, jade_variant);
    [M, N] = size(prob.P);
    assert(size(best_ind, 1) == M && size(best_ind, 2) == N, 'Wrong dimensions');
    % Check it's a valid permutation (each job column appears once)
    assert(best_fit > 0, 'Fitness must be positive');
    fprintf(' done\n');

    %% Test 2: JADE converges (monotonically non-increasing best)
    fprintf('    [2/4] Monotonic convergence...');
    [~, ~, ~, ~, ~, best_per_gen] = de_flowshop(prob, 30, 15, 'evaluate_makespan', false, 0.5, jade_variant);
    for g = 2:length(best_per_gen)
        assert(best_per_gen(g) <= best_per_gen(g-1), ...
            sprintf('Best increased at gen %d: %d > %d', g, best_per_gen(g), best_per_gen(g-1)));
    end
    fprintf(' done\n');

    %% Test 3: JADE works on larger problems (20x10)
    fprintf('    [3/4] Works on 20x10...');
    p10 = load_problems('data/taillard_20x10.json');
    [~, fit10] = de_flowshop(p10(1), 30, 10, 'evaluate_makespan', false, 0.5, jade_variant);
    assert(fit10 > 0 && fit10 < 10000, 'Fitness out of range');
    fprintf(' done\n');

    %% Test 4: JADE works on 20x20
    fprintf('    [4/4] Works on 20x20...');
    p20 = load_problems('data/taillard_20x20.json');
    [~, fit20] = de_flowshop(p20(1), 30, 10, 'evaluate_makespan', false, 0.5, jade_variant);
    assert(fit20 > 0 && fit20 < 20000, 'Fitness out of range');
    fprintf(' done\n');

    fprintf('  All JADE tests passed!\n');
end
