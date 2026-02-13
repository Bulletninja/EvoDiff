function [perm_out, ms, ls_evals] = local_search_insert(P, perm_flat, M, N)
% LOCAL_SEARCH_INSERT Insertion neighborhood local search for PFSP
%
% For each job, removes it and tries reinserting at every other position.
% Keeps the first improving move found. Repeats until no improvement.
%
% Args:
%   P         - Original processing times matrix (machines x jobs)
%   perm_flat - Current solution as flattened M*N x 1 vector
%   M         - Number of machines
%   N         - Number of jobs
%
% Returns:
%   perm_out - Improved solution as flattened M*N x 1 vector
%   ms       - Makespan of improved solution
%   ls_evals - Number of fitness evaluations used

    perm = reshape(perm_flat, M, N);
    ms = evaluate_makespan(perm);
    ls_evals = 1;

    improved = true;
    while improved
        improved = false;
        for j = 1:N
            job_col = perm(:, j);
            reduced = perm(:, [1:j-1, j+1:N]);
            for pos = 1:(N-1)
                trial = [reduced(:, 1:pos-1), job_col, reduced(:, pos:end)];
                trial_ms = evaluate_makespan(trial);
                ls_evals = ls_evals + 1;
                if trial_ms < ms
                    ms = trial_ms;
                    perm = trial;
                    improved = true;
                    break;
                end
            end
            if improved
                break;
            end
        end
    end

    perm_out = perm(:);
end
