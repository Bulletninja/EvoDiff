function offspring = order_crossover(p, m, M, N)
% ORDER_CROSSOVER Order Crossover (OX1) for permutation-based DE
%
% Copies a random segment of job order from parent 1, then fills
% remaining positions with jobs from parent 2 in their relative order.
% Preserves relative-order information from both parents.
%
% Args:
%   p - First parent (flattened M*N x 1 vector)
%   m - Second parent (flattened M*N x 1 vector)
%   M - Number of machines
%   N - Number of jobs
%
% Returns:
%   offspring - Crossover result (flattened M*N x 1 vector)

    p_mat = reshape(p, M, N);
    m_mat = reshape(m, M, N);

    % Map parent 2's columns to parent 1's column indices
    % m_as_p(k) = j means column k of m_mat matches column j of p_mat
    m_as_p = zeros(1, N);
    for k = 1:N
        for j = 1:N
            if isequal(m_mat(:,k), p_mat(:,j))
                m_as_p(k) = j;
                break;
            end
        end
    end

    % Select random crossover segment [i1, i2]
    pts = sort(randperm(N, 2));
    i1 = pts(1);
    i2 = pts(2);

    % OX1: copy segment from parent 1 (identity indices in p_mat's frame)
    child = zeros(1, N);
    child(i1:i2) = i1:i2;
    segment = i1:i2;

    % Fill remaining positions from parent 2 in relative order
    m_filtered = m_as_p(~ismember(m_as_p, segment));
    fill_pos = [1:i1-1, i2+1:N];
    child(fill_pos) = m_filtered;

    % child is a permutation of 1:N (column indices in p_mat)
    offspring = p_mat(:, child);
    offspring = offspring(:);
end
