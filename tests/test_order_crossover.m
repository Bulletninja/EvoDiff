function test_order_crossover()
% TEST_ORDER_CROSSOVER - Unit tests for OX1 crossover operator

    fprintf('  Testing order crossover (OX1)...\n');

    %% Test 1: Offspring is valid permutation
    fprintf('    [1/5] Valid permutation output...');
    P = [54 83 15 71 77; 79 3 11 99 56; 16 89 49 15 89];
    M = 3; N = 5;
    p1 = P(:);  % identity order
    p2 = P(:, [3 1 5 2 4]);
    p2 = p2(:);
    valid_count = 0;
    for trial = 1:20
        offspring = order_crossover(p1, p2, M, N);
        off_mat = reshape(offspring, M, N);
        orig_sorted = sortrows(P')';
        off_sorted = sortrows(off_mat')';
        if isequal(orig_sorted, off_sorted)
            valid_count = valid_count + 1;
        end
    end
    assert(valid_count == 20, ...
        sprintf('All 20 offspring should be valid permutations, got %d', valid_count));
    fprintf(' done\n');

    %% Test 2: Identical parents produce copy
    fprintf('    [2/5] Identical parents...');
    p_same = P(:);
    for trial = 1:10
        offspring = order_crossover(p_same, p_same, M, N);
        assert(isequal(offspring, p_same), 'Identical parents should produce identical offspring');
    end
    fprintf(' done\n');

    %% Test 3: Output length correct
    fprintf('    [3/5] Output dimensions...');
    offspring = order_crossover(p1, p2, M, N);
    assert(length(offspring) == M * N, ...
        sprintf('Output length should be %d, got %d', M*N, length(offspring)));
    fprintf(' done\n');

    %% Test 4: Diversity — different random segments produce different offspring
    fprintf('    [4/5] Diversity across calls...');
    results = zeros(M*N, 20);
    for i = 1:20
        results(:,i) = order_crossover(p1, p2, M, N);
    end
    unique_count = 1;
    for i = 2:20
        is_dup = false;
        for j = 1:i-1
            if isequal(results(:,i), results(:,j))
                is_dup = true;
                break;
            end
        end
        if ~is_dup
            unique_count = unique_count + 1;
        end
    end
    assert(unique_count >= 2, 'OX1 should produce diverse offspring from different segments');
    fprintf(' done\n');

    %% Test 5: Two-job case (N=2, minimal)
    fprintf('    [5/5] Two-job edge case...');
    P2 = [10 20; 5 15];
    M2 = 2; N2 = 2;
    p1_small = P2(:);
    p2_small = P2(:, [2 1]);
    p2_small = p2_small(:);
    offspring = order_crossover(p1_small, p2_small, M2, N2);
    off_mat = reshape(offspring, M2, N2);
    orig_sorted = sortrows(P2')';
    off_sorted = sortrows(off_mat')';
    assert(isequal(orig_sorted, off_sorted), 'Two-job OX1 should produce valid permutation');
    fprintf(' done\n');

    fprintf('  All order crossover tests passed!\n');
end
