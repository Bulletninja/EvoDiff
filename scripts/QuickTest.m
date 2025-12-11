% QuickTest - Fast validation run
% 1 problem, 3 runs each (normal + selective)
% ~30 seconds total

FS = load_taillard_problems();  % Load benchmark data

fprintf('\n========================================\n');
fprintf('QUICK TEST: Problem 1, 3 runs\n');
fprintf('========================================\n');

N = 3;              % Only 3 runs (instead of 30)
generaciones = 20;  % Only 20 generations (instead of 100)
NP = 100;           % Smaller population (instead of 500)

j = 1;  % Only problem 1
fprintf('\nPROBLEM %d (lb=%d, ub=%d)\n', j, FS(j).lb, FS(j).ub);

for i=1:N
   fprintf('  Run %d/%d - Normal...', i, N);
   tic;
   [mejorind, mejorval, nfeval, difflb, diffub, mejores] = EvoDif_Programa(FS(j), NP, generaciones, 'Makespan', false);
   elapsed = toc;
   fprintf(' %.1fs (best=%.0f, err_lb=%.1f%%)\n', elapsed, mejorval, 100*difflb/FS(j).lb);

   fprintf('  Run %d/%d - Selective...', i, N);
   tic;
   [mejorind, mejorval, nfeval, difflb, diffub, mejores] = EvoDif_Programa(FS(j), NP, generaciones, 'Makespan', true);
   elapsed = toc;
   fprintf(' %.1fs (best=%.0f, err_lb=%.1f%%)\n', elapsed, mejorval, 100*difflb/FS(j).lb);
end

fprintf('\nQuick test completed!\n');
