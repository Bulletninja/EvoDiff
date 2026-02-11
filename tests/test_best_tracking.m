function test_best_tracking()
% TEST_BEST_TRACKING - Test that best individual is properly tracked
%
% Validates that best_individual is updated during evolution when
% better offspring are found.

    fprintf('  Testing best individual tracking...\n');

    %% Test 1: Best tracking in simple run
    fprintf('    [1/3] Basic best tracking...');

    Prob.P = [10 20 30; 15 25 35];
    Prob.lb = 90;
    Prob.ub = 100;

    NP = 20;
    gen = 5;
    [best_ind, best_val, num_evals, difflb, diffub, best_per_gen] = ...
        de_flowshop(Prob, NP, gen, 'evaluate_makespan', false);

    assert(~isempty(best_ind), 'Best individual should not be empty');
    assert(best_val > 0 && best_val < Inf, ...
        'Best fitness should be finite and positive');
    fprintf(' done\n');

    %% Test 2: Best should improve or stay same over generations
    fprintf('    [2/3] Best monotonicity...');

    for i = 2:length(best_per_gen)
        assert(best_per_gen(i) <= best_per_gen(i-1), ...
            sprintf('Best should not get worse: gen %d (%.2f) > gen %d (%.2f)', ...
            i, best_per_gen(i), i-1, best_per_gen(i-1)));
    end
    fprintf(' done\n');

    %% Test 3: Returned best matches reported best
    fprintf('    [3/3] Consistency check...');

    actual_fitness = evaluate_makespan(best_ind);

    assert(abs(actual_fitness - best_val) < 1e-10, ...
        sprintf('Returned best fitness (%.6f) should match actual (%.6f)', ...
        best_val, actual_fitness));
    fprintf(' done\n');

    fprintf('  All best tracking tests passed!\n');
end
