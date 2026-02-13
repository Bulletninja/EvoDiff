function animate_gantt(P, schedule, problem_id, save_path)
% ANIMATE_GANTT Step-by-step animated GIF of schedule construction
%
% Shows jobs being placed one at a time into the Gantt chart, revealing
% how the schedule builds incrementally. Each frame adds one job across
% all machines. The active job is highlighted; previous jobs are dimmed.
% A makespan marker tracks the current C_max.
%
% Args:
%   P          - Original processing times matrix (M x N)
%   schedule   - Processing times in scheduled job order (M x N)
%   problem_id - Problem number (for title)
%   save_path  - File path to save the animated GIF

    [M, N] = size(schedule);

    % Compute full schedule makespan for fixed X-axis
    [full_ms, ~] = evaluate_makespan(schedule);

    % Map scheduled columns to original job indices (once, before animation)
    job_indices = zeros(1, N);
    for j = 1:N
        for k = 1:size(P, 2)
            if isequal(schedule(:, j), P(:, k))
                job_indices(j) = k;
                break;
            end
        end
    end

    % Generate stable job colors (same seed as plot_gantt)
    job_colors = jet(size(P, 2));
    rng_state = rng();
    rng(42);
    job_colors = job_colors(randperm(size(P, 2)), :);
    rng(rng_state);

    % Render frames as temp PNGs
    tmp_dir = tempname();
    mkdir(tmp_dir);
    frame_files = {};

    for step = 1:N
        partial = schedule(:, 1:step);
        [ms_k, C_mat_k] = evaluate_makespan(partial);
        S_mat_k = C_mat_k - partial;

        % Critical path on partial schedule
        crit_path = compute_critical_path(C_mat_k, M, step);
        crit_set = false(M, step);
        for idx = 1:size(crit_path, 1)
            crit_set(crit_path(idx, 1), crit_path(idx, 2)) = true;
        end

        fig = figure('Visible', 'off', 'Position', [100 100 900 350]);
        hold on;

        for i = 1:M
            for j = 1:step
                x = S_mat_k(i, j);
                w = partial(i, j);
                y = M - i + 1;
                h = 0.7;

                col = [0.8 0.8 0.8];
                if job_indices(j) > 0
                    col = job_colors(job_indices(j), :);
                end

                % Dim previous jobs, highlight active job
                if j < step
                    col = col * 0.5 + 0.5;  % lighten toward white
                    edge_col = [0.5 0.5 0.5];
                    edge_w = 0.5;
                elseif crit_set(i, j)
                    edge_col = [0.8 0.1 0.1];
                    edge_w = 2;
                else
                    edge_col = [0.2 0.2 0.2];
                    edge_w = 1.2;
                end

                rectangle('Position', [x, y - h/2, w, h], ...
                    'FaceColor', col, 'EdgeColor', edge_col, 'LineWidth', edge_w);

                % Job label
                if w > full_ms * 0.02 && job_indices(j) > 0
                    text(x + w/2, y, sprintf('%d', job_indices(j)), ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                        'FontSize', 7);
                end
            end
        end

        % Makespan marker
        plot([ms_k ms_k], [0.5 M + 0.5], 'r--', 'LineWidth', 1.5);
        text(ms_k, M + 0.7, sprintf('C_{max}=%d', ms_k), ...
            'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', 'r');

        % Idle gap indicators: light gray fill where machine waits
        for i = 1:M
            prev_end = 0;
            for j = 1:step
                gap_start = prev_end;
                gap_end = S_mat_k(i, j);
                if gap_end > gap_start + 0.5
                    rectangle('Position', [gap_start, (M - i + 1) - h/2, gap_end - gap_start, h], ...
                        'FaceColor', [0.93 0.93 0.93], 'EdgeColor', 'none');
                end
                prev_end = C_mat_k(i, j);
            end
        end

        hold off;
        set(gca, 'YTick', 1:M, 'YTickLabel', ...
            fliplr(arrayfun(@(x) sprintf('M%d', x), 1:M, 'UniformOutput', false)));
        xlabel('Time');
        ylabel('Machine');
        title(sprintf('Problem %d — Schedule Build: Job %d/%d (C_{max}=%d)', ...
            problem_id, step, N, ms_k));
        xlim([0, full_ms * 1.05]);
        ylim([0.3, M + 0.9]);
        grid on;

        fname = fullfile(tmp_dir, sprintf('frame_%03d.png', step));
        print(fig, fname, '-dpng', '-r150');
        close(fig);
        frame_files{end+1} = fname;
    end

    % Stitch into animated GIF using ImageMagick
    % First frame: 200cs (2s), middle frames: 100cs (1s), last frame: 400cs (4s)
    if length(frame_files) >= 3
        cmd = sprintf('magick -loop 0 -delay 200 %s -delay 100 %s -delay 400 %s %s', ...
            frame_files{1}, ...
            strjoin(frame_files(2:end-1), ' '), ...
            frame_files{end}, ...
            save_path);
    elseif length(frame_files) == 2
        cmd = sprintf('magick -loop 0 -delay 200 %s -delay 400 %s %s', ...
            frame_files{1}, frame_files{end}, save_path);
    else
        cmd = sprintf('magick -loop 0 -delay 400 %s %s', frame_files{1}, save_path);
    end

    [status, output] = system(cmd);
    if status ~= 0
        warning('animate_gantt:convertFailed', ...
            'ImageMagick magick failed: %s', output);
    end

    % Cleanup temp files
    for k = 1:length(frame_files)
        delete(frame_files{k});
    end
    if exist(tmp_dir, 'dir')
        rmdir(tmp_dir);
    end
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
