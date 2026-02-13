function generate_statistical_tables(results, tables_dir)
% GENERATE_STATISTICAL_TABLES Produce LaTeX tables with statistical tests
%
% Generates:
%   1. Pairwise Wilcoxon rank-sum test table (p-values between all variant pairs)
%   2. Friedman test result with mean ranks
%   3. Comprehensive results summary with ARPD, std, best, and significance markers
%
% Args:
%   results    - Struct array from run_experiment()
%   tables_dir - Directory for output .tex files

    num_problems = length(results);
    num_variants = length(results(1).variants);

    if num_variants < 2
        return;
    end

    % Collect final RPD values per variant across all problems
    % rpd_matrix(p, v) = mean RPD for problem p, variant v
    rpd_matrix = zeros(num_problems, num_variants);
    % rpd_all{v} = vector of all final RPDs across problems and runs
    rpd_all = cell(num_variants, 1);
    for v = 1:num_variants
        rpd_all{v} = [];
    end

    for p = 1:num_problems
        for v = 1:num_variants
            fv = results(p).variants(v).stats.vals(:, end);
            rpd_runs = 100 * (fv - results(p).ub) / results(p).ub;
            rpd_matrix(p, v) = mean(rpd_runs);
            rpd_all{v} = [rpd_all{v}; rpd_runs];
        end
    end

    % === 1. Pairwise Wilcoxon rank-sum test ===
    pairwise_file = fullfile(tables_dir, 'pairwise_wilcoxon.tex');
    fid = fopen(pairwise_file, 'w');
    if fid == -1
        error('generate_statistical_tables:openFailed', 'Cannot open %s', pairwise_file);
    end
    cleanup1 = onCleanup(@() fclose(fid));

    fprintf(fid, '\\begin{table}[h]\n');
    fprintf(fid, '\\centering\n');
    fprintf(fid, '\\caption{Pairwise Wilcoxon Rank-Sum Test (p-values)}\n');

    col_spec = '|l|';
    for v = 1:num_variants
        col_spec = [col_spec, 'c|'];
    end
    fprintf(fid, '\\begin{tabular}{%s}\n', col_spec);
    fprintf(fid, '\\hline\n');

    % Header
    fprintf(fid, ' ');
    for v = 1:num_variants
        fprintf(fid, ' & %s', results(1).variants(v).name);
    end
    fprintf(fid, ' \\\\ \\hline\n');

    % p-value matrix
    p_matrix = ones(num_variants);
    for i = 1:num_variants
        fprintf(fid, '%s', results(1).variants(i).name);
        for j = 1:num_variants
            if i == j
                fprintf(fid, ' & ---');
            elseif i < j
                [pval, ~, ~] = wilcoxon_ranksum(rpd_all{i}, rpd_all{j});
                p_matrix(i, j) = pval;
                p_matrix(j, i) = pval;
                if pval < 0.001
                    fprintf(fid, ' & $<$0.001***');
                elseif pval < 0.01
                    fprintf(fid, ' & %.3f**', pval);
                elseif pval < 0.05
                    fprintf(fid, ' & %.3f*', pval);
                else
                    fprintf(fid, ' & %.3f', pval);
                end
            else
                % Mirror the upper triangle
                if p_matrix(i, j) < 0.001
                    fprintf(fid, ' & $<$0.001***');
                elseif p_matrix(i, j) < 0.01
                    fprintf(fid, ' & %.3f**', p_matrix(i, j));
                elseif p_matrix(i, j) < 0.05
                    fprintf(fid, ' & %.3f*', p_matrix(i, j));
                else
                    fprintf(fid, ' & %.3f', p_matrix(i, j));
                end
            end
        end
        fprintf(fid, ' \\\\ \\hline\n');
    end

    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\\vspace{2mm}\n');
    fprintf(fid, '\\footnotesize{* $p<0.05$, ** $p<0.01$, *** $p<0.001$}\n');
    fprintf(fid, '\\end{table}\n');
    clear cleanup1;

    % === 2. Friedman test ===
    [fri_p, fri_chi2, fri_ranks] = friedman_test(rpd_matrix);

    friedman_file = fullfile(tables_dir, 'friedman_test.tex');
    fid = fopen(friedman_file, 'w');
    if fid == -1
        error('generate_statistical_tables:openFailed', 'Cannot open %s', friedman_file);
    end
    cleanup2 = onCleanup(@() fclose(fid));

    fprintf(fid, '\\begin{table}[h]\n');
    fprintf(fid, '\\centering\n');
    fprintf(fid, '\\caption{Friedman Test — Variant Rankings}\n');
    fprintf(fid, '\\begin{tabular}{|l|r|r|}\n');
    fprintf(fid, '\\hline\n');
    fprintf(fid, 'Variant & ARPD (\\%%) & Mean Rank \\\\ \\hline\n');

    arpd = mean(rpd_matrix, 1);
    for v = 1:num_variants
        fprintf(fid, '%s & %.2f & %.2f \\\\ \\hline\n', ...
            results(1).variants(v).name, arpd(v), fri_ranks(v));
    end

    fprintf(fid, '\\hline\n');
    fprintf(fid, '\\multicolumn{3}{|l|}{$\\chi^2 = %.2f$, $df = %d$, $p = %.4f$', ...
        fri_chi2, num_variants - 1, fri_p);
    if fri_p < 0.001
        fprintf(fid, ' ***');
    elseif fri_p < 0.01
        fprintf(fid, ' **');
    elseif fri_p < 0.05
        fprintf(fid, ' *');
    end
    fprintf(fid, '} \\\\ \\hline\n');

    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\\end{table}\n');
    clear cleanup2;

    % === 3. Comprehensive summary table ===
    summary_file = fullfile(tables_dir, 'comprehensive_summary.tex');
    fid = fopen(summary_file, 'w');
    if fid == -1
        error('generate_statistical_tables:openFailed', 'Cannot open %s', summary_file);
    end
    cleanup3 = onCleanup(@() fclose(fid));

    fprintf(fid, '\\begin{table}[h]\n');
    fprintf(fid, '\\centering\n');
    fprintf(fid, '\\caption{Comprehensive Results Summary — %d Taillard Instances}\n', num_problems);

    col_spec = '|l|';
    for v = 1:num_variants
        col_spec = [col_spec, 'r|'];
    end
    fprintf(fid, '\\begin{tabular}{%s}\n', col_spec);
    fprintf(fid, '\\hline\n');

    % Header
    fprintf(fid, 'Metric');
    for v = 1:num_variants
        fprintf(fid, ' & %s', results(1).variants(v).name);
    end
    fprintf(fid, ' \\\\ \\hline\n');

    % ARPD
    fprintf(fid, 'ARPD (\\%%)');
    [~, best_arpd_idx] = min(arpd);
    for v = 1:num_variants
        if v == best_arpd_idx
            fprintf(fid, ' & \\textbf{%.2f}', arpd(v));
        else
            fprintf(fid, ' & %.2f', arpd(v));
        end
    end
    fprintf(fid, ' \\\\ \\hline\n');

    % Std of RPD
    fprintf(fid, 'Std RPD');
    for v = 1:num_variants
        fprintf(fid, ' & %.2f', std(rpd_all{v}));
    end
    fprintf(fid, ' \\\\ \\hline\n');

    % Best RPD
    fprintf(fid, 'Best RPD (\\%%)');
    for v = 1:num_variants
        fprintf(fid, ' & %.2f', min(rpd_all{v}));
    end
    fprintf(fid, ' \\\\ \\hline\n');

    % Worst RPD
    fprintf(fid, 'Worst RPD (\\%%)');
    for v = 1:num_variants
        fprintf(fid, ' & %.2f', max(rpd_all{v}));
    end
    fprintf(fid, ' \\\\ \\hline\n');

    % Friedman rank
    fprintf(fid, 'Friedman Rank');
    [~, best_rank_idx] = min(fri_ranks);
    for v = 1:num_variants
        if v == best_rank_idx
            fprintf(fid, ' & \\textbf{%.2f}', fri_ranks(v));
        else
            fprintf(fid, ' & %.2f', fri_ranks(v));
        end
    end
    fprintf(fid, ' \\\\ \\hline\n');

    % # Problems won (lowest mean RPD)
    fprintf(fid, 'Problems Won');
    wins = zeros(1, num_variants);
    for p = 1:num_problems
        [~, winner] = min(rpd_matrix(p, :));
        wins(winner) = wins(winner) + 1;
    end
    for v = 1:num_variants
        fprintf(fid, ' & %d/%d', wins(v), num_problems);
    end
    fprintf(fid, ' \\\\ \\hline\n');

    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\\end{table}\n');
    clear cleanup3;

    fprintf('Statistical tables: pairwise Wilcoxon, Friedman test, comprehensive summary\n');
end
