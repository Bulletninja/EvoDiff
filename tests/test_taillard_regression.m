function test_taillard_regression()
% TEST_TAILLARD_REGRESSION - Regression test against Taillard benchmark
%
% Runs DE on problem 1 with a fixed seed and verifies the makespan
% falls within the known bounds. Serves as a smoke test.

    fprintf('  Testing Taillard regression...\n');

    %% Test 1: Problem 1 within bounds
    fprintf('    [1/2] Problem 1 bounded result...');

    problems = load_problems('data/taillard_20x5.json');
    prob = problems(1);

    % Fixed seed for determinism
    rng(42);
    NP = 100;
    gen = 30;
    [best_ind, best_val, ~, ~, ~, ~] = ...
        de_flowshop(prob, NP, gen, 'evaluate_makespan', false);

    % Best should be reasonable (not astronomically high)
    % With 100 pop, 30 gen, should get within ~2x of upper bound
    assert(best_val < prob.ub * 2, ...
        sprintf('Best (%.0f) should be < 2x upper bound (%d)', best_val, prob.ub * 2));
    assert(best_val >= prob.lb, ...
        sprintf('Best (%.0f) should be >= lower bound (%d)', best_val, prob.lb));
    fprintf(' done\n');

    %% Test 2: Re-evaluation matches
    fprintf('    [2/2] Re-evaluation consistency...');
    reeval = evaluate_makespan(best_ind);
    assert(abs(reeval - best_val) < 1e-10, ...
        sprintf('Re-eval (%.6f) should match best_val (%.6f)', reeval, best_val));
    fprintf(' done\n');

    fprintf('  All Taillard regression tests passed!\n');
end
