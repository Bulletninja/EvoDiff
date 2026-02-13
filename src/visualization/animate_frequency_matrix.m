function animate_frequency_matrix(pop_snapshots, P, save_path, sample_rate)
% ANIMATE_FREQUENCY_MATRIX Animated GIF of job-position frequency across generations
%
% Visualizes how population diversity evolves by showing a heatmap of
% "how often does job j appear in position k" across the population.
% Early generations show diffuse (diverse) distributions; late generations
% converge toward specific job orderings.
%
% Args:
%   pop_snapshots - Cell array of population matrices (M*N x NP_gen) per generation
%   P             - Original processing times matrix (M x N) for job identification
%   save_path     - File path to save the animated GIF
%   sample_rate   - (Optional) Sample every Nth generation (default: 1 = all)

    if nargin < 4 || isempty(sample_rate)
        sample_rate = 1;
    end

    [M, N] = size(P);
    num_gens = length(pop_snapshots);

    % Build job column lookup
    P_cols = cell(N, 1);
    for j = 1:N
        P_cols{j} = P(:, j);
    end

    % Select generations to render
    gen_indices = 1:sample_rate:num_gens;
    if gen_indices(end) ~= num_gens
        gen_indices(end+1) = num_gens;
    end

    % Render frames as temp PNGs
    tmp_dir = tempname();
    mkdir(tmp_dir);
    frame_files = {};

    for gi = 1:length(gen_indices)
        g = gen_indices(gi);
        pop = pop_snapshots{g};
        if isempty(pop)
            continue;
        end

        NP_gen = size(pop, 2);

        % Build frequency matrix: freq(job, position) = count
        freq = zeros(N, N);
        for ind = 1:NP_gen
            schedule = reshape(pop(:, ind), M, N);
            for pos = 1:N
                col = schedule(:, pos);
                for j = 1:N
                    if isequal(col, P_cols{j})
                        freq(j, pos) = freq(j, pos) + 1;
                        break;
                    end
                end
            end
        end

        % Normalize to probability [0, 1]
        freq = freq / NP_gen;

        % Render frame
        fig = figure('Visible', 'off', 'Position', [100 100 600 500]);

        imagesc(freq);
        colormap(fig, hot(256));
        caxis([0, 1]);
        cb = colorbar();
        ylabel(cb, 'Frequency');

        set(gca, 'XTick', 1:N, 'YTick', 1:N);
        xlabel('Position');
        ylabel('Job');
        title(sprintf('Job-Position Frequency  Gen %d (NP=%d)', g - 1, NP_gen));

        % Add frequency labels for cells above threshold
        for r = 1:N
            for c = 1:N
                if freq(r, c) >= 0.15
                    if freq(r, c) > 0.5
                        tc = 'k';
                    else
                        tc = 'w';
                    end
                    text(c, r, sprintf('%.0f%%', freq(r, c) * 100), ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                        'FontSize', 7, 'Color', tc, 'FontWeight', 'bold');
                end
            end
        end

        fname = fullfile(tmp_dir, sprintf('frame_%03d.png', gi));
        print(fig, fname, '-dpng', '-r150');
        close(fig);
        frame_files{end+1} = fname;
    end

    % Stitch into animated GIF using ImageMagick
    if ~isempty(frame_files) && nargin >= 3 && ~isempty(save_path)
        % Build magick command: 50cs per frame, 200cs for last frame, loop forever
        cmd = sprintf('magick -delay 50 -loop 0 %s -delay 200 %s %s', ...
            strjoin(frame_files(1:end-1), ' '), frame_files{end}, save_path);
        [status, output] = system(cmd);
        if status ~= 0
            warning('animate_frequency_matrix:convertFailed', ...
                'ImageMagick convert failed: %s', output);
        end
    end

    % Cleanup temp files
    for k = 1:length(frame_files)
        delete(frame_files{k});
    end
    if exist(tmp_dir, 'dir')
        rmdir(tmp_dir);
    end
end
