function perm = neh_heuristic(P)
% NEH_HEURISTIC Nawaz-Enscore-Ham constructive heuristic for PFSP
%
% Builds a high-quality permutation by sorting jobs by decreasing total
% processing time, then iteratively inserting each job at the position
% that minimizes partial makespan.
%
% Args:
%   P - Processing times matrix (machines x jobs)
%
% Returns:
%   perm - Flattened column vector (M*N x 1) with NEH job order

    [M, N] = size(P);

    % Sort jobs by decreasing total processing time
    total_time = sum(P, 1);
    [~, order] = sort(total_time, 'descend');

    % Start with the first job
    seq = order(1);

    % Iteratively insert remaining jobs at the best position
    for k = 2:N
        job = order(k);
        best_ms = Inf;
        best_pos = 1;
        for pos = 1:(length(seq) + 1)
            trial = [seq(1:pos-1), job, seq(pos:end)];
            ms = evaluate_makespan(P(:, trial));
            if ms < best_ms
                best_ms = ms;
                best_pos = pos;
            end
        end
        seq = [seq(1:best_pos-1), job, seq(best_pos:end)];
    end

    perm = P(:, seq);
    perm = perm(:);
end
