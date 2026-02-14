function offspring = jade_permutation_crossover(current, pbest, x_r, CR, seg_len, M, N)
% JADE_PERMUTATION_CROSSOVER Adaptive crossover for permutation DE
%
% Adapts DE/current-to-pbest/1 for permutations:
%   1. OX1 crossover between current and pbest with F-controlled segment
%   2. CR-controlled perturbation via swap moves inspired by x_r
%
% Args:
%   current  - Current individual (M*N x 1 flattened)
%   pbest    - Best from top p% (M*N x 1 flattened)
%   x_r      - Random from population+archive (M*N x 1 flattened)
%   CR       - Crossover rate [0,1]
%   seg_len  - Segment length for OX1 (controlled by F)
%   M, N     - Dimensions

    cur_mat = reshape(current, M, N);
    pb_mat = reshape(pbest, M, N);
    xr_mat = reshape(x_r, M, N);

    % Step 1: OX1-like crossover between current and pbest
    % Segment from pbest, rest filled from current's relative order
    start = randi(N);
    seg_end = start + seg_len - 1;
    if seg_end > N
        seg_end = N;
    end

    % Build mapping: which column in cur_mat matches each column in pb_mat
    % (by content equality)
    pb_to_cur = zeros(1, N);
    for k = 1:N
        for j = 1:N
            if isequal(pb_mat(:,k), cur_mat(:,j))
                pb_to_cur(k) = j;
                break;
            end
        end
    end

    % Child permutation (indices into pb_mat columns)
    child_perm = zeros(1, N);
    child_perm(start:seg_end) = start:seg_end;
    placed = child_perm(start:seg_end);

    % Fill rest from current's order mapped through pbest
    cur_order_in_pb = pb_to_cur;
    % Remove placed positions
    remaining = setdiff(1:N, placed);
    % Get cur positions not already placed, in current's order
    cur_cols_remaining = [];
    for j = 1:N
        col_in_pb = find(pb_to_cur == j);
        if ~isempty(col_in_pb) && ~any(col_in_pb == placed)
            cur_cols_remaining = [cur_cols_remaining, col_in_pb];
        end
    end

    fill_idx = 1;
    for k = [seg_end+1:N, 1:start-1]
        if fill_idx <= length(cur_cols_remaining)
            child_perm(k) = cur_cols_remaining(fill_idx);
            fill_idx = fill_idx + 1;
        end
    end

    % Construct offspring from pbest columns in child_perm order
    child_mat = pb_mat(:, child_perm);

    % Step 2: CR-controlled perturbation inspired by x_r
    % For each position, with probability CR, swap toward x_r's arrangement
    if CR > 0
        % Build x_r's ordering
        xr_to_child = zeros(1, N);
        for k = 1:N
            for j = 1:N
                if isequal(xr_mat(:,k), child_mat(:,j))
                    xr_to_child(k) = j;
                    break;
                end
            end
        end

        % Apply CR-controlled swap moves
        for k = 1:N
            if rand() < CR && xr_to_child(k) ~= k
                % Swap columns k and xr_to_child(k) in child
                target = xr_to_child(k);
                if target > 0 && target <= N
                    tmp = child_mat(:, k);
                    child_mat(:, k) = child_mat(:, target);
                    child_mat(:, target) = tmp;
                    % Update mapping
                    old_target = xr_to_child(k);
                    xr_to_child(xr_to_child == k) = old_target;
                    xr_to_child(k) = k;
                end
            end
        end
    end

    offspring = child_mat(:);
end
