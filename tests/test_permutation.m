function test_permutation()
% TEST_PERMUTATION - Test permutation operations maintain validity
%
% Tests that permutarTrabajos generates valid permutations

    fprintf('  Testing permutation operations...\n');

    %% Test 1: Basic permutation validity
    fprintf('    [1/3] Valid permutation generation...');

    % Create 3x5 problem (3 machines, 5 jobs)
    J = [1 2 3 4 5; 6 7 8 9 10; 11 12 13 14 15];

    % Generate permutation
    J_perm = permutarTrabajos(J);

    % Reshape back
    [M, N] = size(J);
    J_perm_reshaped = reshape(J_perm, M, N);

    % Each column should be one of the original jobs
    original_jobs = J;
    permuted_jobs = J_perm_reshaped;

    % Check all original jobs are present
    for i = 1:N
        found = false;
        for j = 1:N
            if isequal(original_jobs(:,i), permuted_jobs(:,j))
                found = true;
                break;
            end
        end
        assert(found, sprintf('Job %d not found in permutation', i));
    end

    fprintf(' ✓\n');

    %% Test 2: Multiple permutations are different
    fprintf('    [2/3] Randomness test...');

    % Generate 10 permutations
    perms = zeros(M*N, 10);
    for i = 1:10
        perms(:,i) = permutarTrabajos(J);
    end

    % At least some should be different (probability of all same is negligible)
    all_same = true;
    for i = 2:10
        if ~isequal(perms(:,1), perms(:,i))
            all_same = false;
            break;
        end
    end

    assert(~all_same, 'Permutations should vary (check randomness)');

    fprintf(' ✓\n');

    %% Test 3: Size preservation
    fprintf('    [3/3] Size preservation...');

    J_test = rand(4, 6);  % 4 machines, 6 jobs
    J_perm_test = permutarTrabajos(J_test);

    assert(length(J_perm_test) == numel(J_test), ...
        'Permutation should preserve total size');

    fprintf(' ✓\n');

    fprintf('  All permutation tests passed!\n');
end
