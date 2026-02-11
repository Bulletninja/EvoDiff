function test_de_flowshop()
% TEST_DE_FLOWSHOP - Test the main DE algorithm
%
% Tests:
%   1. Small problem convergence
%   2. Best tracking monotonicity
%   3. Stats struct correctness
%   4. Selective mode runs

    fprintf('  Testing de_flowshop...\n');

    Prob.P = [10 20 30 40; 15 25 35 45; 8 18 28 38];
    Prob.lb = 100;
    Prob.ub = 200;

    %% Test 1: Convergence on small problem
    fprintf('    [1/4] Small problem convergence...');
    NP = 30;
    gen = 10;
    [best_ind, best_val, num_evals, difflb, diffub, best_per_gen] = ...
        de_flowshop(Prob, NP, gen, 'evaluate_makespan', false);

    assert(best_val > 0 && best_val < Inf, 'Best fitness should be finite');
    [M, N] = size(Prob.P);
    assert(isequal(size(best_ind), [M, N]), 'Best individual should be MxN');
    fprintf(' done\n');

    %% Test 2: Best per gen is monotonically non-increasing
    fprintf('    [2/4] Monotonicity...');
    for i = 2:length(best_per_gen)
        assert(best_per_gen(i) <= best_per_gen(i-1), ...
            sprintf('best_per_gen should not increase: gen %d > gen %d', i, i-1));
    end
    fprintf(' done\n');

    %% Test 3: Stats correctness
    fprintf('    [3/4] Stats correctness...');
    assert(num_evals > 0, 'Should have positive eval count');
    assert(length(best_per_gen) == gen, 'best_per_gen length should match generations');
    % Verify best_val matches the re-evaluated best individual
    reeval = evaluate_makespan(best_ind);
    assert(abs(reeval - best_val) < 1e-10, 'Re-evaluated best should match');
    fprintf(' done\n');

    %% Test 4: Selective mode
    fprintf('    [4/4] Selective mode...');
    [best_ind_s, best_val_s, ~, ~, ~, ~] = ...
        de_flowshop(Prob, NP, gen, 'evaluate_makespan', true);
    assert(best_val_s > 0 && best_val_s < Inf, 'Selective best should be finite');
    fprintf(' done\n');

    fprintf('  All de_flowshop tests passed!\n');
end
