function animate_convergence_race(results, problem_idx, save_path)
% ANIMATE_CONVERGENCE_RACE Animated GIF of variant convergence curves racing
%
% Shows convergence curves growing generation-by-generation with moving
% dot markers at the current frontier. Each frame extends all curves by
% one generation, creating a "race" effect between variants.
%
% Args:
%   results     - Struct array from run_experiment()
%   problem_idx - Index of the problem to animate
%   save_path   - File path to save the animated GIF

    num_variants = length(results(problem_idx).variants);
    colors = {[0.12 0.47 0.71], [1.0 0.5 0.05], [0.17 0.63 0.17], ...
              [0.84 0.15 0.16], [0.58 0.40 0.74], [0.55 0.34 0.29]};

    % Compute mean convergence curve per variant
    max_gen = size(results(problem_idx).variants(1).stats.vals, 2);
    mu = zeros(num_variants, max_gen);
    for v = 1:num_variants
        mu(v, :) = mean(results(problem_idx).variants(v).stats.vals, 1);
    end

    % Y-axis limits (fixed across all frames)
    y_min = min(mu(:));
    y_max = max(mu(:));
    y_range = y_max - y_min;
    if y_range < 1
        y_range = max(y_max * 0.05, 10);  % at least 5% or 10 units
    end
    y_lo = y_min - y_range * 0.08;
    y_hi = y_max + y_range * 0.08;

    % Reference lines
    ub = results(problem_idx).ub;
    lb = results(problem_idx).lb;

    % Render frames
    tmp_dir = tempname();
    mkdir(tmp_dir);
    frame_files = {};

    for gen = 1:max_gen
        fig = figure('Visible', 'off', 'Position', [100 100 700 450]);
        hold on;

        % Reference lines (full width)
        plot([1, max_gen], [lb, lb], 'g--', 'LineWidth', 0.8);
        plot([1, max_gen], [ub, ub], 'k--', 'LineWidth', 0.8);

        legend_handles = [];
        legend_labels = {};

        for v = 1:num_variants
            c = colors{mod(v-1, length(colors)) + 1};

            % Draw curve up to current generation
            x = 1:gen;
            h = plot(x, mu(v, 1:gen), 'Color', c, 'LineWidth', 2);

            % Moving dot at frontier
            plot(gen, mu(v, gen), 'o', 'Color', c, ...
                'MarkerSize', 8, 'MarkerFaceColor', c);

            % Label at frontier
            text(gen + 0.3, mu(v, gen), sprintf('%.0f', mu(v, gen)), ...
                'FontSize', 8, 'Color', c, 'FontWeight', 'bold');

            legend_handles(end+1) = h;
            legend_labels{end+1} = results(problem_idx).variants(v).name;
        end

        % Add reference line handles to legend
        h_lb = plot(NaN, NaN, 'g--', 'LineWidth', 0.8);
        h_ub = plot(NaN, NaN, 'k--', 'LineWidth', 0.8);
        legend_handles(end+1) = h_lb;
        legend_labels{end+1} = 'LB';
        legend_handles(end+1) = h_ub;
        legend_labels{end+1} = 'UB';

        hold off;
        legend(legend_handles, legend_labels{:}, 'Location', 'northeast');
        xlabel('Generation');
        ylabel('Mean Best Makespan');
        title(sprintf('Problem %d — Convergence Race (Gen %d/%d)', ...
            problem_idx, gen, max_gen));
        xlim([1, max_gen]);
        ylim([y_lo, y_hi]);
        grid on;

        fname = fullfile(tmp_dir, sprintf('frame_%03d.png', gen));
        print(fig, fname, '-dpng', '-r150');
        close(fig);
        frame_files{end+1} = fname;
    end

    % Stitch into animated GIF using ImageMagick
    if length(frame_files) >= 3
        cmd = sprintf('magick -loop 0 -delay 150 %s -delay 80 %s -delay 300 %s %s', ...
            frame_files{1}, ...
            strjoin(frame_files(2:end-1), ' '), ...
            frame_files{end}, ...
            save_path);
    elseif length(frame_files) == 2
        cmd = sprintf('magick -loop 0 -delay 150 %s -delay 300 %s %s', ...
            frame_files{1}, frame_files{end}, save_path);
    else
        cmd = sprintf('magick -loop 0 -delay 300 %s %s', frame_files{1}, save_path);
    end

    [status, output] = system(cmd);
    if status ~= 0
        warning('animate_convergence_race:convertFailed', ...
            'ImageMagick magick failed: %s', output);
    end

    % Cleanup
    for k = 1:length(frame_files)
        delete(frame_files{k});
    end
    if exist(tmp_dir, 'dir')
        rmdir(tmp_dir);
    end
end
