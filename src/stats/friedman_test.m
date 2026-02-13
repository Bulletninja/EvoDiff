function [p, chi2, ranks_mean] = friedman_test(data)
% FRIEDMAN_TEST Friedman non-parametric test for repeated measures
%
% Tests whether multiple treatments (variants) have identical effects
% across multiple blocks (problems). Non-parametric alternative to
% repeated-measures ANOVA.
%
% Args:
%   data - Matrix of size (num_blocks x num_treatments)
%          Each row is a block (problem), each column is a treatment (variant)
%          Values should be the metric to compare (e.g., mean RPD)
%
% Returns:
%   p          - p-value from chi-squared distribution
%   chi2       - Friedman chi-squared statistic
%   ranks_mean - Mean rank per treatment (lower = better)

    [n, k] = size(data);  % n blocks, k treatments

    % Rank within each block (row)
    ranks = zeros(n, k);
    for i = 1:n
        [~, order] = sort(data(i, :));
        r = zeros(1, k);
        r(order) = 1:k;

        % Handle ties: average ranks for tied values
        [sorted, ~] = sort(data(i, :));
        j = 1;
        while j <= k
            jj = j;
            while jj <= k && sorted(jj) == sorted(j)
                jj = jj + 1;
            end
            if jj > j + 1
                avg = mean(j:jj-1);
                for idx = j:jj-1
                    r(order(idx)) = avg;
                end
            end
            j = jj;
        end
        ranks(i, :) = r;
    end

    % Mean rank per treatment
    ranks_mean = mean(ranks, 1);

    % Friedman statistic
    R_sum = sum(ranks, 1);  % sum of ranks per treatment
    chi2 = 12 / (n * k * (k + 1)) * sum(R_sum.^2) - 3 * n * (k + 1);

    % p-value from chi-squared distribution with k-1 degrees of freedom
    df = k - 1;
    p = 1 - chi2cdf(chi2, df);
end


function p = chi2cdf(x, df)
% Chi-squared CDF via incomplete gamma function
    if x <= 0
        p = 0;
    else
        p = gammainc(x / 2, df / 2);
    end
end
