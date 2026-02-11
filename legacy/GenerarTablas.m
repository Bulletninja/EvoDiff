for i=1:10
    nom=sprintf('TaillardFS_%d.tex',i);
    %lb,ub,difflb,diffub,relerrlb,relerrub,mejorval,nfeval
    datos_i=sprintf('datos_%d.mat',i);
    load(datos_i)
    FID1=fopen(nom,'w')   
    fprintf('\\begin{table}[h]\n')
    fprintf('\\begin{tabular}{|l|l|}\n')
    fprintf('\\hline\n')
    fprintf('\\multicolumn{2}{|c|}{Taillard Flowshop (20x5)%d} \\\\ \\hline\n',i)
    fprintf('Cota inferior (CI)                & %d        \\\\ \\hline\n',lb)
    fprintf('Cota superior (CS)                & %d        \\\\ \\hline\n',ub)
    fprintf('Diferencia CI                     & %d        \\\\ \\hline\n',difflb)
    fprintf('Diferencia CS                     & %d        \\\\ \\hline\n',diffub)
    fprintf('Error relativo CI                 & %f        \\\\ \\hline\n',relerrlb)
    fprintf('Error relativo CS                 & %f        \\\\ \\hline\n',relerrub)
    fprintf('Mejor valor                       & %d        \\\\ \\hline\n',mejorval)
    fprintf('Evaluaciones de la función        & %d        \\\\ \\hline\n',nfeval)
    fprintf('\\end{tabular}\n')
    fprintf('\\end{table}\n')
    fclose(FID1)
    
    
    nommejorind=sprintf('TaillardFS_mejorindividuo_%d.tex',i);
    FID2=fopen(nommejorind,'w')
    fprintf('\\begin{table}[h]\n')
    fprintf('\\begin{tabular}{|l|l|l|l|l|l|l|l|l|l|l|l|l|l|l|l|l|l|l|l|}\n')
    fprintf('\\hline\n')
    fprintf('\\multicolumn{2}{|c|}{Taillard Flowshop (20x5) mejor individuo %d} \\\\ \\hline\n',i)
    for k=1:5
        fprintf('%d & %d & %d & %d & %d & %d & %d & %d & %d & %d & %d & %d & %d & %d & %d & %d & %d & %d & %d & %d \\\\ \\hline\n',...
            mejorindividuo(k,1),mejorindividuo(k,2),mejorindividuo(k,3),mejorindividuo(k,4),mejorindividuo(k,5),...
            mejorindividuo(k,6),mejorindividuo(k,7),mejorindividuo(k,8),mejorindividuo(k,9),mejorindividuo(k,10),...
            mejorindividuo(k,11),mejorindividuo(k,12),mejorindividuo(k,13),mejorindividuo(k,14),mejorindividuo(k,15),...
            mejorindividuo(k,16),mejorindividuo(k,17),mejorindividuo(k,18),mejorindividuo(k,19),mejorindividuo(k,20))
    end
    fprintf('\\end{tabular}\n')
    fprintf('\\end{table}\n')
    fclose(FID2)
end