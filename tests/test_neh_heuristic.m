function test_neh_heuristic()
% TEST_NEH_HEURISTIC - Unit tests for NEH constructive heuristic

    fprintf('  Testing NEH heuristic...\n');

    %% Test 1: Output is valid permutation
    fprintf('    [1/5] Valid permutation output...');
    P = [54 83 15 71 77 36 53 38 27 87 76 91 14 29 12 77 32 87 68 94;
         79  3 11 99 56 70 99 60  5 56  3 61 73 75 47 14 21 86  5 77;
         16 89 49 15 89 45 60 23 57 64  7  1 63 41 63 47 26 75 77 40;
         66 58 31 68 78 91 13 59 49 85 85 72 12 90 20 28 48 33 78 39;
         58 56 20 85 53 35 53 41 69 13 86 72 49 70 21 30  3 28 23 45];
    perm = neh_heuristic(P);
    [M, N] = size(P);
    assert(length(perm) == M * N, 'Output length should be M*N');
    perm_mat = reshape(perm, M, N);
    orig_sorted = sortrows(P')';
    result_sorted = sortrows(perm_mat')';
    assert(isequal(orig_sorted, result_sorted), 'Output should be a permutation of input columns');
    fprintf(' done\n');

    %% Test 2: NEH produces better-than-random solution
    fprintf('    [2/5] Quality vs random...');
    neh_ms = evaluate_makespan(perm_mat);
    rand_makespans = zeros(1, 20);
    for i = 1:20
        rp = random_permutation(P);
        rand_makespans(i) = evaluate_makespan(reshape(rp, M, N));
    end
    assert(neh_ms <= median(rand_makespans), ...
        sprintf('NEH (%d) should beat median random (%d)', neh_ms, median(rand_makespans)));
    fprintf(' done\n');

    %% Test 3: Known small instance (2 machines, 3 jobs)
    fprintf('    [3/5] Known small instance...');
    P_small = [10 20 30; 5 15 25];
    perm_small = neh_heuristic(P_small);
    perm_small_mat = reshape(perm_small, 2, 3);
    ms_neh = evaluate_makespan(perm_small_mat);
    % Try all 6 permutations, find the optimum
    perms = perms(1:3);
    best_ms = Inf;
    for i = 1:size(perms, 1)
        ms_trial = evaluate_makespan(P_small(:, perms(i,:)));
        if ms_trial < best_ms
            best_ms = ms_trial;
        end
    end
    assert(ms_neh == best_ms, ...
        sprintf('NEH should find optimum on 3-job instance: got %d, optimal %d', ms_neh, best_ms));
    fprintf(' done\n');

    %% Test 4: Single job (N=1)
    fprintf('    [4/5] Single job edge case...');
    P_one = [10; 20; 30];
    perm_one = neh_heuristic(P_one);
    assert(isequal(perm_one, P_one(:)), 'Single job should return itself');
    fprintf(' done\n');

    %% Test 5: Jobs sorted by decreasing total time
    fprintf('    [5/5] Sorting correctness...');
    % With 2 jobs, NEH should place the one with higher total time first
    P_two = [1 10; 2 20];  % Job 1 total=3, Job 2 total=30
    perm_two = neh_heuristic(P_two);
    perm_two_mat = reshape(perm_two, 2, 2);
    % Job 2 (higher total) should be placed first in the initial sequence
    % Then job 1 inserted at best position
    ms_two = evaluate_makespan(perm_two_mat);
    % Verify it's the best of the 2 possible orderings
    ms_alt = evaluate_makespan(P_two(:, [2 1]));
    ms_orig = evaluate_makespan(P_two);
    assert(ms_two <= min(ms_alt, ms_orig), 'NEH should find best 2-job ordering');
    fprintf(' done\n');

    fprintf('  All NEH heuristic tests passed!\n');
end
