function offspring = permutation_mutate(p, m, M, N)
% PERMUTATION_MUTATE Mutation operator for permutation-based DE
%
% Finds jobs that differ in position between two parents and randomly
% permutes only those differing jobs. The first parent is used as the
% template; the second parent is used only for comparison.
%
% Args:
%   p - First parent (flattened M*N x 1 vector)
%   m - Second parent (flattened M*N x 1 vector)
%   M - Number of machines
%   N - Number of jobs
%
% Returns:
%   offspring - Mutated individual (flattened M*N x 1 vector)

    p = reshape(p, M, N);
    m = reshape(m, M, N);
    offspring = p;

    differs = prod(double(p ~= m));
    indx = 1:N;
    c = indx .* differs;
    c(c == 0) = [];

    offspring(:, c) = offspring(:, c(randperm(length(c))));
    offspring = offspring(:);
end
