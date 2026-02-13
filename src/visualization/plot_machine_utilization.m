function plot_machine_utilization(P, schedule, problem_id, save_path)
% PLOT_MACHINE_UTILIZATION Stacked bar chart of processing vs idle time per machine
%
% Shows how each machine's total time is split between processing and idle.
% Machine 1 always has 100% utilization in PFSP.
%
% Args:
%   P          - Original processing times matrix (M x N)
%   schedule   - Processing times in scheduled job order (M x N)
%   problem_id - Problem number (for title)
%   save_path  - File path to save the figure (optional)

    [M, N] = size(schedule);
    [makespan, C_mat] = evaluate_makespan(schedule);

    processing = sum(schedule, 2);         % total processing time per machine
    completion = C_mat(:, N);              % last job completion per machine
    idle = completion - processing;        % idle time per machine
    utilization = 100 * processing ./ completion;

    fig = figure('Visible', 'off', 'Position', [100 100 600 300]);
    barh(1:M, [processing, idle], 'stacked');
    colormap([0.27 0.51 0.71; 0.85 0.85 0.85]);

    % Add utilization labels
    for i = 1:M
        text(completion(i) + makespan * 0.01, i, sprintf('%.0f%%', utilization(i)), ...
            'VerticalAlignment', 'middle', 'FontSize', 9);
    end

    set(gca, 'YTick', 1:M, 'YTickLabel', arrayfun(@(x) sprintf('M%d', x), 1:M, 'UniformOutput', false));
    xlabel('Time');
    ylabel('Machine');
    title(sprintf('Problem %d — Machine Utilization', problem_id));
    legend('Processing', 'Idle', 'Location', 'southeast');

    if nargin >= 4 && ~isempty(save_path)
        print(fig, save_path, '-dpng', '-r200');
    end
    close(fig);
end
