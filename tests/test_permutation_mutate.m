function test_permutation_mutate()
% TEST_PERMUTATION_MUTATE - Test the permutation mutation operator
%
% Tests:
%   1. Output is valid permutation
%   2. Output diversity (produces different results)
%   3. Determinism with identical parents (no change)

    fprintf('  Testing permutation_mutate...\n');

    %% Test 1: Output validity
    fprintf('    [1/3] Output validity...');

    M = 3; N = 5;
    J = [1 2 3 4 5; 6 7 8 9 10; 11 12 13 14 15];
    p1 = J(:);
    p2 = J(:, [3 1 2 5 4]);  % Different permutation
    p2 = p2(:);

    offspring = permutation_mutate(p1, p2, M, N);

    % Offspring should be same size
    assert(length(offspring) == M*N, 'Offspring should be M*N elements');

    % Reshape and check each column is a valid job
    off_mat = reshape(offspring, M, N);
    for i = 1:N
        found = false;
        for j = 1:N
            if isequal(J(:,i), off_mat(:,j))
                found = true;
                break;
            end
        end
        assert(found, sprintf('Job %d not found in offspring', i));
    end
    fprintf(' done\n');

    %% Test 2: Diversity
    fprintf('    [2/3] Diversity test...');
    results = zeros(M*N, 20);
    for i = 1:20
        results(:,i) = permutation_mutate(p1, p2, M, N);
    end
    all_same = true;
    for i = 2:20
        if ~isequal(results(:,1), results(:,i))
            all_same = false;
            break;
        end
    end
    assert(~all_same, 'Mutation should produce different results');
    fprintf(' done\n');

    %% Test 3: Identical parents produce identical offspring
    fprintf('    [3/3] Identical parents...');
    offspring_same = permutation_mutate(p1, p1, M, N);
    assert(isequal(offspring_same, p1), ...
        'Identical parents should produce identical offspring');
    fprintf(' done\n');

    fprintf('  All permutation_mutate tests passed!\n');
end
