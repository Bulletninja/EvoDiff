function test_permutation()
% TEST_PERMUTATION - Test permutation operations maintain validity
%
% Tests that random_permutation generates valid permutations

    fprintf('  Testing permutation operations...\n');

    %% Test 1: Basic permutation validity
    fprintf('    [1/3] Valid permutation generation...');

    J = [1 2 3 4 5; 6 7 8 9 10; 11 12 13 14 15];

    J_perm = random_permutation(J);

    [M, N] = size(J);
    J_perm_reshaped = reshape(J_perm, M, N);

    % Each column should be one of the original jobs
    for i = 1:N
        found = false;
        for j = 1:N
            if isequal(J(:,i), J_perm_reshaped(:,j))
                found = true;
                break;
            end
        end
        assert(found, sprintf('Job %d not found in permutation', i));
    end
    fprintf(' done\n');

    %% Test 2: Multiple permutations are different
    fprintf('    [2/3] Randomness test...');

    perms = zeros(M*N, 10);
    for i = 1:10
        perms(:,i) = random_permutation(J);
    end

    all_same = true;
    for i = 2:10
        if ~isequal(perms(:,1), perms(:,i))
            all_same = false;
            break;
        end
    end
    assert(~all_same, 'Permutations should vary (check randomness)');
    fprintf(' done\n');

    %% Test 3: Size preservation
    fprintf('    [3/3] Size preservation...');

    J_test = rand(4, 6);
    J_perm_test = random_permutation(J_test);

    assert(length(J_perm_test) == numel(J_test), ...
        'Permutation should preserve total size');
    fprintf(' done\n');

    fprintf('  All permutation tests passed!\n');
end
