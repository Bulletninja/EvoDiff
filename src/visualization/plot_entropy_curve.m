function plot_entropy_curve(pop_snapshots, P, save_path)
% PLOT_ENTROPY_CURVE Population diversity via Shannon entropy over generations
%
% Computes the average positional entropy of the job-position frequency
% matrix at each generation. High entropy = diverse population (uniform
% job placement). Low entropy = converged population (jobs locked into
% fixed positions). Normalized to [0, 1] where 1 = maximum diversity.
%
% Args:
%   pop_snapshots - Cell array of population matrices (M*N x NP) per generation
%   P             - Original processing times matrix (M x N)
%   save_path     - File path to save the figure (optional)

    [M, N] = size(P);
    num_gens = length(pop_snapshots);

    % Build job column lookup
    P_cols = cell(N, 1);
    for j = 1:N
        P_cols{j} = P(:, j);
    end

    max_entropy = log2(N);  % entropy of uniform distribution over N jobs
    entropy_vals = zeros(num_gens, 1);

    for g = 1:num_gens
        pop = pop_snapshots{g};
        if isempty(pop)
            entropy_vals(g) = NaN;
            continue;
        end

        NP_gen = size(pop, 2);

        % Build frequency matrix: freq(job, position)
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

        % Normalize to probabilities
        freq = freq / NP_gen;

        % Compute Shannon entropy per position, then average
        H = 0;
        for pos = 1:N
            p = freq(:, pos);
            p = p(p > 0);  % avoid log(0)
            H = H - sum(p .* log2(p));
        end
        H = H / N;  % average across positions

        % Normalize to [0, 1]
        entropy_vals(g) = H / max_entropy;
    end

    % Plot
    gens = 0:(num_gens - 1);

    fig = figure('Visible', 'off', 'Position', [100 100 700 400]);
    hold on;

    % Entropy curve
    plot(gens, entropy_vals, 'b-', 'LineWidth', 2);

    % Reference lines
    plot(xlim(), [1 1], 'g--', 'LineWidth', 0.8);  % max diversity
    plot(xlim(), [0 0], 'r--', 'LineWidth', 0.8);  % full convergence

    % Markers at start and end
    plot(gens(1), entropy_vals(1), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    plot(gens(end), entropy_vals(end), 'rs', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

    % Annotations
    text(gens(1) + 0.3, entropy_vals(1) + 0.03, ...
        sprintf('%.3f', entropy_vals(1)), 'FontSize', 9, 'Color', 'b');
    text(gens(end) - 1.5, entropy_vals(end) - 0.04, ...
        sprintf('%.3f', entropy_vals(end)), 'FontSize', 9, 'Color', 'r');

    hold off;
    xlabel('Generation');
    ylabel('Normalized Entropy');
    title('Population Diversity (Positional Entropy)');
    ylim([-0.05, 1.1]);
    grid on;
    legend({'Entropy', 'Max diversity', 'Full convergence'}, 'Location', 'northeast');

    if nargin >= 3 && ~isempty(save_path)
        print(fig, save_path, '-dpng', '-r200');
    end
    close(fig);
end
