function problem = do_small_instance(M, N, seed)
% DO_SMALL_INSTANCE Create a deterministic small problem from seed
%
% Shared helper for acceptance test drivers. Does not touch random state.

    values = zeros(M, N);
    for i = 1:M
        for j = 1:N
            values(i, j) = mod(seed * 7 + i * 13 + j * 17, 50) + 1;
        end
    end
    problem.P = values;
    problem.lb = max(max(sum(values, 2)), max(sum(values, 1)));
    problem.ub = sum(values(:));
end
