function test_de_variants()
% TEST_DE_VARIANTS - Tests variant configurations in de_flowshop

    fprintf('  Testing DE variant configurations...\n');

    % Small problem for speed
    P = [54 83 15 71 77; 79 3 11 99 56; 16 89 49 15 89];
    Prob.P = P;
    Prob.lb = max(max(sum(P, 2)), max(sum(P, 1)));
    Prob.ub = sum(P(:));

    NP = 20;
    max_gen = 10;
    f = 'evaluate_makespan';
    [M, N] = size(P);

    %% Test 1: Random initialization (init_method='random')
    fprintf('    [1/10] init_method=random...');
    variant = struct('init_method', 'random', 'crossover', 'ox1', ...
        'local_search', false, 'population_reduction', false, ...
        'selective', false, 'selection_ratio', 0.5, ...
        'local_search_interval', 10, 'name', 'test_random_init');
    [best, fit, evals, ~, ~, bpg] = de_flowshop(Prob, NP, max_gen, f, false, 0.5, variant);
    assert(isfinite(fit), 'Random init should produce finite fitness');
    assert(fit >= Prob.lb, 'Fitness should be >= lower bound');
    assert(isequal(size(best), [M, N]), 'Best individual should be MxN');
    fprintf(' done\n');

    %% Test 2: Column-diff crossover (crossover='column_diff')
    fprintf('    [2/10] crossover=column_diff...');
    variant = struct('init_method', 'neh', 'crossover', 'column_diff', ...
        'local_search', false, 'population_reduction', false, ...
        'selective', false, 'selection_ratio', 0.5, ...
        'local_search_interval', 10, 'name', 'test_coldiff');
    [best, fit, ~, ~, ~, ~] = de_flowshop(Prob, NP, max_gen, f, false, 0.5, variant);
    assert(isfinite(fit), 'Column-diff crossover should produce finite fitness');
    best_sorted = sortrows(best')';
    orig_sorted = sortrows(P')';
    assert(isequal(best_sorted, orig_sorted), 'Result should be valid permutation');
    fprintf(' done\n');

    %% Test 3: No local search (local_search=false)
    fprintf('    [3/10] local_search=false...');
    variant = struct('init_method', 'neh', 'crossover', 'ox1', ...
        'local_search', false, 'population_reduction', true, ...
        'selective', false, 'selection_ratio', 0.5, ...
        'local_search_interval', 10, 'name', 'test_no_ls');
    [~, fit_no_ls, evals_no_ls, ~, ~, ~] = de_flowshop(Prob, NP, max_gen, f, false, 0.5, variant);
    % With local search
    variant_ls = variant;
    variant_ls.local_search = true;
    variant_ls.local_search_interval = 5;
    variant_ls.name = 'test_with_ls';
    [~, ~, evals_ls, ~, ~, ~] = de_flowshop(Prob, NP, max_gen, f, false, 0.5, variant_ls);
    assert(evals_ls >= evals_no_ls, ...
        sprintf('LS version (%d evals) should use >= no-LS (%d evals)', evals_ls, evals_no_ls));
    fprintf(' done\n');

    %% Test 4: No population reduction (population_reduction=false)
    fprintf('    [4/10] population_reduction=false...');
    variant = struct('init_method', 'neh', 'crossover', 'ox1', ...
        'local_search', false, 'population_reduction', false, ...
        'selective', false, 'selection_ratio', 0.5, ...
        'local_search_interval', 10, 'name', 'test_no_reduction');
    [~, fit, evals, ~, ~, bpg] = de_flowshop(Prob, NP, max_gen, f, false, 0.5, variant);
    assert(isfinite(fit), 'No-reduction variant should produce finite fitness');
    expected_evals = NP + NP * max_gen;
    assert(evals == expected_evals, ...
        sprintf('Without reduction, expected %d evals, got %d', expected_evals, evals));
    fprintf(' done\n');

    %% Test 5: Minimal config (NP=2, max_gen=1)
    fprintf('    [5/10] Minimal NP=2, gen=1...');
    variant = struct('init_method', 'random', 'crossover', 'ox1', ...
        'local_search', false, 'population_reduction', false, ...
        'selective', false, 'selection_ratio', 0.5, ...
        'local_search_interval', 10, 'name', 'test_minimal');
    [best, fit, evals, difflb, diffub, bpg] = de_flowshop(Prob, 2, 1, f, false, 0.5, variant);
    assert(isfinite(fit), 'Minimal run should produce finite fitness');
    assert(evals >= 2, 'Should have at least NP initial evaluations');
    assert(length(bpg) == 1, 'Should have 1 generation of history');
    assert(difflb >= 0, 'Difference from LB should be non-negative');
    fprintf(' done\n');

    %% Test 6: Selective + column_diff
    fprintf('    [6/10] selective + column_diff...');
    variant = struct('init_method', 'neh', 'crossover', 'column_diff', ...
        'local_search', false, 'population_reduction', false, ...
        'selective', true, 'selection_ratio', 0.3, ...
        'local_search_interval', 10, 'name', 'sel_coldiff');
    [best, fit, evals, ~, ~, ~] = de_flowshop(Prob, NP, max_gen, f, true, 0.3, variant);
    assert(isfinite(fit), 'Selective+coldiff should produce finite fitness');
    % Selective breeds fewer => fewer evals per gen
    mid = ceil(0.3 * NP);
    assert(evals <= NP + mid * max_gen + 10, 'Selective should use fewer evals');
    fprintf(' done\n');

    %% Test 7: Random init + population reduction
    fprintf('    [7/10] random + pop_reduction...');
    variant = struct('init_method', 'random', 'crossover', 'ox1', ...
        'local_search', false, 'population_reduction', true, ...
        'selective', false, 'selection_ratio', 0.5, ...
        'local_search_interval', 10, 'name', 'rand_popred');
    [best, fit, ~, ~, ~, ~] = de_flowshop(Prob, NP, max_gen, f, false, 0.5, variant);
    assert(isfinite(fit), 'Random+reduction should produce finite fitness');
    assert(isequal(size(best), [M, N]), 'Should return valid dimensions');
    fprintf(' done\n');

    %% Test 8: JADE + selective
    fprintf('    [8/10] jade + selective...');
    variant = struct('init_method', 'neh', 'crossover', 'ox1', ...
        'local_search', false, 'population_reduction', false, ...
        'selective', true, 'selection_ratio', 0.5, ...
        'local_search_interval', 10, 'name', 'jade_sel', ...
        'jade', true, 'jade_c', 0.1, 'jade_p', 0.2);
    [best, fit, ~, ~, ~, ~] = de_flowshop(Prob, NP, max_gen, f, true, 0.5, variant);
    assert(isfinite(fit), 'JADE+selective should produce finite fitness');
    assert(fit >= Prob.lb, 'Fitness should be >= lower bound');
    fprintf(' done\n');

    %% Test 9: JADE + random init + population reduction
    fprintf('    [9/10] jade + random + pop_reduction...');
    variant = struct('init_method', 'random', 'crossover', 'ox1', ...
        'local_search', false, 'population_reduction', true, ...
        'selective', false, 'selection_ratio', 0.5, ...
        'local_search_interval', 10, 'name', 'jade_rand_red', ...
        'jade', true, 'jade_c', 0.1, 'jade_p', 0.1);
    [best, fit, ~, ~, ~, ~] = de_flowshop(Prob, NP, max_gen, f, false, 0.5, variant);
    assert(isfinite(fit), 'JADE+random+reduction should produce finite fitness');
    fprintf(' done\n');

    %% Test 10: Full hybrid — all features enabled
    fprintf('    [10/10] Full hybrid (all features)...');
    variant = struct('init_method', 'neh', 'crossover', 'ox1', ...
        'local_search', true, 'population_reduction', true, ...
        'selective', true, 'selection_ratio', 0.5, ...
        'local_search_interval', 5, 'name', 'full_hybrid', ...
        'jade', true, 'jade_c', 0.1, 'jade_p', 0.1);
    [best, fit, evals, difflb, ~, bpg] = de_flowshop(Prob, NP, max_gen, f, true, 0.5, variant);
    assert(isfinite(fit), 'Full hybrid should produce finite fitness');
    assert(fit >= Prob.lb, 'Fitness should be >= lower bound');
    assert(evals > NP, 'Should use more than NP evaluations');
    assert(difflb >= 0, 'Difference from LB should be non-negative');
    fprintf(' done\n');

    fprintf('  All DE variant tests passed!\n');
end
