function plot_gantt(P, schedule, problem_id, save_path)
% PLOT_GANTT Render a flowshop schedule as a Gantt chart with critical path
%
% Draws machines on Y-axis, time on X-axis, jobs as colored blocks.
% The critical path is highlighted with red borders.
%
% Args:
%   P          - Original processing times matrix (M x N)
%   schedule   - Processing times in scheduled job order (M x N)
%   problem_id - Problem number (for title)
%   save_path  - File path to save the figure (optional)

    [M, N] = size(schedule);

    % Compute completion time matrix
    [makespan, C_mat] = evaluate_makespan(schedule);

    % Compute start times: start = completion - processing
    S_mat = C_mat - schedule;

    % Map scheduled columns back to original job indices
    job_indices = zeros(1, N);
    for j = 1:N
        for k = 1:size(P, 2)
            if isequal(schedule(:, j), P(:, k))
                job_indices(j) = k;
                break;
            end
        end
    end

    % Generate distinguishable colors for jobs
    job_colors = jet(size(P, 2));
    % Shuffle to avoid adjacent similar colors
    rng_state = rng();
    rng(42);
    job_colors = job_colors(randperm(size(P, 2)), :);
    rng(rng_state);

    % Compute critical path
    crit_path = compute_critical_path(C_mat, M, N);
    crit_set = false(M, N);
    for k = 1:size(crit_path, 1)
        crit_set(crit_path(k, 1), crit_path(k, 2)) = true;
    end

    % Draw
    fig = figure('Visible', 'off', 'Position', [100 100 900 350]);
    hold on;

    for i = 1:M
        for j = 1:N
            x = S_mat(i, j);
            w = schedule(i, j);
            y = M - i + 1;  % flip so machine 1 is at top
            h = 0.7;

            col = [0.8 0.8 0.8];  % fallback gray
            if job_indices(j) > 0
                col = job_colors(job_indices(j), :);
            end

            % Draw block
            if crit_set(i, j)
                rectangle('Position', [x, y - h/2, w, h], ...
                    'FaceColor', col, 'EdgeColor', [0.8 0.1 0.1], 'LineWidth', 2);
            else
                rectangle('Position', [x, y - h/2, w, h], ...
                    'FaceColor', col, 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.5);
            end

            % Label with job number if block is wide enough
            if w > makespan * 0.025 && job_indices(j) > 0
                text(x + w/2, y, sprintf('%d', job_indices(j)), ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                    'FontSize', 7);
            end
        end
    end

    % Makespan line
    plot([makespan makespan], [0.5 M + 0.5], 'r--', 'LineWidth', 1.5);
    text(makespan, M + 0.7, sprintf('C_{max}=%d', makespan), ...
        'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', 'r');

    hold off;
    set(gca, 'YTick', 1:M, 'YTickLabel', fliplr(arrayfun(@(x) sprintf('M%d', x), 1:M, 'UniformOutput', false)));
    xlabel('Time');
    ylabel('Machine');
    title(sprintf('Problem %d — Gantt Chart (makespan = %d)', problem_id, makespan));
    xlim([0, makespan * 1.05]);
    ylim([0.3, M + 0.9]);

    if nargin >= 4 && ~isempty(save_path)
        print(fig, save_path, '-dpng', '-r200');
    end
    close(fig);
end


function path = compute_critical_path(C_mat, M, N)
% Backtrack from C_mat(M,N) to (1,1) following the critical path
    path = [];
    i = M; j = N;
    while i >= 1 && j >= 1
        path = [path; i, j];
        if i == 1 && j == 1
            break;
        elseif i == 1
            j = j - 1;
        elseif j == 1
            i = i - 1;
        elseif C_mat(i-1, j) >= C_mat(i, j-1)
            i = i - 1;
        else
            j = j - 1;
        end
    end
    path = flipud(path);
end
