function [C, C_mat] = evaluate_makespan(O)
% EVALUATE_MAKESPAN Calculate flow shop makespan (total completion time)
%
% Uses dynamic programming to compute the completion time matrix.
% The makespan is the completion time of the last job on the last machine.
%
% Args:
%   O - Processing times matrix (machines x jobs), already in job order
%
% Returns:
%   C     - Makespan value (completion time of last job on last machine)
%   C_mat - Full completion time matrix (machines x jobs), optional

    % CR-104: validate input
    assert(~isempty(O) && isnumeric(O) && all(size(O) > 0), ...
        'Processing times matrix must be a non-empty numeric matrix');

    C_mat = O;
    [M, N] = size(C_mat);

    C_mat(1,:) = cumsum(C_mat(1,:));
    C_mat(:,1) = cumsum(C_mat(:,1));
    for j = 2:N
        for i = 2:M
            C_mat(i,j) = C_mat(i,j) + max(C_mat(i-1,j), C_mat(i,j-1));
        end
    end
    C = C_mat(M, N);
end
