function test_best_tracking()
% TEST_BEST_TRACKING - Test that best individual is properly tracked
%
% This test validates Bug #1 fix: ensures mejorindividuo is updated
% during evolution when better offspring are found.

    fprintf('  Testing best individual tracking (Bug #1 fix)...\n');

    %% Test 1: Best tracking in simple run
    fprintf('    [1/3] Basic best tracking...');

    % Create simple 2x3 problem
    Prob.P = [10 20 30; 15 25 35];
    Prob.lb = 90;
    Prob.ub = 100;

    % Run short evolution
    NP = 20;          % Small population
    gen = 5;          % Few generations
    [best_ind, best_val, nfeval, difflb, diffub, mejores] = ...
        EvoDif_Programa(Prob, NP, gen, 'Makespan', false);

    % Verify best individual is not empty
    assert(~isempty(best_ind), 'Best individual should not be empty');

    % Verify best fitness is reasonable
    assert(best_val > 0 && best_val < Inf, ...
        'Best fitness should be finite and positive');

    fprintf(' ✓\n');

    %% Test 2: Best should improve or stay same over generations
    fprintf('    [2/3] Best monotonicity...');

    % mejores(i) contains best fitness at generation i
    for i = 2:length(mejores)
        assert(mejores(i) <= mejores(i-1), ...
            sprintf('Best should not get worse: gen %d (%.2f) > gen %d (%.2f)', ...
            i, mejores(i), i-1, mejores(i-1)));
    end

    fprintf(' ✓\n');

    %% Test 3: Returned best matches reported best
    fprintf('    [3/3] Consistency check...');

    % Re-evaluate returned best individual
    [M, N] = size(Prob.P);
    best_ind_reshaped = reshape(best_ind, M, N);
    actual_fitness = Makespan(best_ind_reshaped);

    % Should match within floating point tolerance
    assert(abs(actual_fitness - best_val) < 1e-10, ...
        sprintf('Returned best fitness (%.6f) should match actual (%.6f)', ...
        best_val, actual_fitness));

    fprintf(' ✓\n');

    fprintf('  All best tracking tests passed!\n');
end
