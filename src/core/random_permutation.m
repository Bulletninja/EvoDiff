function [J] = random_permutation(J)
% RANDOM_PERMUTATION Generate a random job permutation
%
% Takes a processing times matrix and randomly shuffles the columns (jobs).
% Returns the result as a flattened column vector.
%
% Args:
%   J - Processing times matrix (machines x jobs)
%
% Returns:
%   J - Flattened column vector with randomly permuted job columns

    N = size(J, 2);
    J = J(:, randperm(N));
    J = J(:);
end
