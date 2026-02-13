function test_local_search()
% TEST_LOCAL_SEARCH - Unit tests for insertion neighborhood local search

    fprintf('  Testing local search (insertion)...\n');

    %% Test 1: Never worsens solution
    fprintf('    [1/5] Never worsens...');
    P = [54 83 15 71 77; 79 3 11 99 56; 16 89 49 15 89];
    [M, N] = size(P);
    for trial = 1:5
        rp = random_permutation(P);
        initial_ms = evaluate_makespan(reshape(rp, M, N));
        [improved, ms, ~] = local_search_insert(P, rp, M, N);
        assert(ms <= initial_ms, ...
            sprintf('Local search should not worsen: %d -> %d', initial_ms, ms));
        % Verify reported makespan matches actual
        actual_ms = evaluate_makespan(reshape(improved, M, N));
        assert(ms == actual_ms, ...
            sprintf('Reported makespan %d != actual %d', ms, actual_ms));
    end
    fprintf(' done\n');

    %% Test 2: Output is valid permutation
    fprintf('    [2/5] Valid permutation output...');
    rp = random_permutation(P);
    [improved, ~, ~] = local_search_insert(P, rp, M, N);
    imp_mat = reshape(improved, M, N);
    orig_sorted = sortrows(P')';
    imp_sorted = sortrows(imp_mat')';
    assert(isequal(orig_sorted, imp_sorted), 'Output should be a permutation of input columns');
    assert(length(improved) == M * N, 'Output length should be M*N');
    fprintf(' done\n');

    %% Test 3: Evaluation count is positive and reasonable
    fprintf('    [3/5] Evaluation counting...');
    rp = random_permutation(P);
    [~, ~, ls_evals] = local_search_insert(P, rp, M, N);
    assert(ls_evals >= 1, 'Should have at least 1 evaluation (initial)');
    % Upper bound: at most N*(N-1) per pass, and passes are bounded
    % but we just check it's not absurdly large
    assert(ls_evals <= N * N * N, ...
        sprintf('Eval count %d seems too high for N=%d', ls_evals, N));
    fprintf(' done\n');

    %% Test 4: Already-optimal input returns same solution
    fprintf('    [4/5] Already-optimal stability...');
    % Run local search twice — second time should be a no-op
    rp = random_permutation(P);
    [improved1, ms1, evals1] = local_search_insert(P, rp, M, N);
    [improved2, ms2, evals2] = local_search_insert(P, improved1, M, N);
    assert(ms1 == ms2, 'Second local search should not improve further');
    assert(isequal(improved1, improved2), 'Solution should be unchanged');
    % Second run should use only 1 eval (initial) + N*(N-1) evals finding no improvement
    % But at minimum, evals2 should be much less work than evals1
    fprintf(' done\n');

    %% Test 5: Single job (N=1)
    fprintf('    [5/5] Single job edge case...');
    P_one = [10; 20; 30];
    perm_one = P_one(:);
    [out, ms_one, evals_one] = local_search_insert(P_one, perm_one, 3, 1);
    assert(isequal(out, perm_one), 'Single job should return itself');
    assert(ms_one == evaluate_makespan(P_one), 'Makespan should match');
    assert(evals_one == 1, 'Single job should only need initial evaluation');
    fprintf(' done\n');

    fprintf('  All local search tests passed!\n');
end
