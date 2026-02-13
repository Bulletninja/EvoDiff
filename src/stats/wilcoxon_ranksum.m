function [p, U, z] = wilcoxon_ranksum(x, y)
% WILCOXON_RANKSUM Two-sided Wilcoxon rank-sum (Mann-Whitney U) test
%
% Tests whether two independent samples come from the same distribution.
% Uses normal approximation with continuity correction (valid for n >= 10).
%
% Args:
%   x, y - Two sample vectors
%
% Returns:
%   p - Two-sided p-value
%   U - Mann-Whitney U statistic
%   z - z-score (normal approximation)

    x = x(:);
    y = y(:);
    n1 = length(x);
    n2 = length(y);

    % Combine and rank
    combined = [x; y];
    n = n1 + n2;
    [~, order] = sort(combined);
    ranks = zeros(n, 1);
    ranks(order) = 1:n;

    % Handle ties: assign average rank to tied groups
    [sorted, ~] = sort(combined);
    i = 1;
    while i <= n
        j = i;
        while j <= n && sorted(j) == sorted(i)
            j = j + 1;
        end
        if j > i + 1  % tie group
            avg_rank = mean(i:j-1);
            for k = i:j-1
                ranks(order(k)) = avg_rank;
            end
        end
        i = j;
    end

    % Sum of ranks for first sample
    R1 = sum(ranks(1:n1));

    % Mann-Whitney U statistic
    U1 = R1 - n1 * (n1 + 1) / 2;
    U2 = n1 * n2 - U1;
    U = min(U1, U2);

    % Normal approximation with continuity correction
    mu = n1 * n2 / 2;
    sigma = sqrt(n1 * n2 * (n1 + n2 + 1) / 12);

    % Tie correction for variance
    sorted_vals = sort(combined);
    tie_correction = 0;
    i_t = 1;
    while i_t <= n
        j_t = i_t;
        while j_t <= n && sorted_vals(j_t) == sorted_vals(i_t)
            j_t = j_t + 1;
        end
        t = j_t - i_t;  % tie group size
        if t > 1
            tie_correction = tie_correction + (t^3 - t);
        end
        i_t = j_t;
    end
    tie_correction = tie_correction / (12 * (n * (n - 1)));
    sigma = sqrt(n1 * n2 * ((n + 1) / 12 - tie_correction));

    if sigma == 0
        p = 1;
        z = 0;
        return;
    end

    % Continuity correction
    z = (abs(U1 - mu) - 0.5) / sigma;
    p = 2 * (1 - normcdf(abs(z)));
end


function p = normcdf(x)
% Standard normal CDF via error function
    p = 0.5 * (1 + erf(x / sqrt(2)));
end
