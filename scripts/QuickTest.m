% Quick test - Solo 1 problema, 3 runs
% Para ver resultados rapidos con feedback

InitFlowshop;  % Load FS problems

fprintf('\n========================================\n');
fprintf('QUICK TEST: Problema 1, 3 corridas\n');
fprintf('========================================\n');

N = 3;  % Solo 3 corridas (en lugar de 30)
generaciones = 20;  % Solo 20 generaciones (en lugar de 100)
NP = 100;  % Población más pequeña (en lugar de 500)

j = 1;  % Solo problema 1
fprintf('\nPROBLEMA %d (lb=%d, ub=%d)\n', j, FS(j).lb, FS(j).ub);

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

fprintf('\n✅ Quick test completado!\n');
