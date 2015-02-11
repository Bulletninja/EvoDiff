%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FS.P             -   Matriz de tiempos                                      %
% FS.mejorindividuo-   Mejor individuo encontrado                             %
% FS.mejorvalor    -   Valor del mejor individuo                              %
% FS.lb            -   cota inferior                                          %
% FS.ub            -   cota superior                                          %
% FS.difflb        -   differencias de las soluciones con la cota inferior    %
% FS.diffub        -   differencias de las soluciones con la cota superior    %
% FS.relerrlb      -   error relativo respecto a la cota inferior             %
% FS.relerrlb      -   error relativo respecto a la cota superior             %
% FS.nfeval        -   Evaluaciones del makespan                              %
% FS.vals          -   valores promedio de las poblaciones del mejor individuo%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Flowshop 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS(1).P=[54 83 15 71 77 36 53 38 27 87 76 91 14 29 12 77 32 87 68 94;         %
79  3 11 99 56 70 99 60  5 56  3 61 73 75 47 14 21 86  5 77;                  %
16 89 49 15 89 45 60 23 57 64  7  1 63 41 63 47 26 75 77 40;                  %
66 58 31 68 78 91 13 59 49 85 85  9 39 41 56 40 54 77 51 31;                  %
58 56 20 85 53 35 53 41 69 13 86 72  8 49 47 87 58 18 68 28];                 %
FS(1).mejorindividuo=[];                                                      %
FS(1).mejorval=Inf;                                                           %
FS(1).mejoresvals=[];                                                         %
FS(1).lb=1232;                                                                %
FS(1).ub =1278;                                                               %
FS(1).difflb=Inf;                                                             %
FS(1).diffub=Inf;                                                             %
FS(1).relerrlb=Inf;                                                           %
FS(1).relerrub=Inf;                                                           %
FS(1).nfeval=0;                                                               %
FS(1).vals=[];                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Flowshop 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS(2).P=[26 38 27 88 95 55 54 63 23 45 86 43 43 40 37 54 35 59 43 50;         %
59 62 44 10 23 64 47 68 54  9 30 31 92  7 14 95 76 82 91 37;                  %
78 90 64 49 47 20 61 93 36 47 70 54 87 13 40 34 55 13 11  5;                  %
88 54 47 83 84  9 30 11 92 63 62 75 48 23 85 23  4 31 13 98;                  %
69 30 61 35 53 98 94 33 77 31 54 71 78  9 79 51 76 56 80 72];                 %
FS(2).mejorindividuo=[];                                                      %
FS(2).mejorval=Inf;                                                           %
FS(2).mejoresvals=[];                                                         %
FS(2).lb=1290;                                                                %
FS(2).ub=1359;                                                                %
FS(2).difflb=Inf;                                                             %
FS(2).diffub=Inf;                                                             %
FS(2).relerrlb=Inf;                                                           %
FS(2).relerrub=Inf;                                                           %
FS(2).nfeval=0;                                                               %
FS(2).vals=[];                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Flowshop 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS(3).P=[77 94  9 57 29 79 55 73 65 86 25 39 76 24 38  5 91 29 22 27;         %
 39 31 46 18 93 58 85 58 97 10 79 93  2 87 17 18 10 50  8 26;                 %
 14 21 15 10 85 46 42 18 36  2 44 89  6  3  1 43 81 57 76 59;                 %
 11  2 36 30 89 10 88 22 31  9 43 91 26  3 75 99 63 83 70 84;                 %
 83 13 84 46 20 33 74 42 33 71 32 48 42 99  7 54  8 73 30 75];                %
FS(3).mejorindividuo=[];                                                      %
FS(3).mejorval=Inf;                                                           %
FS(3).mejoresvals=[];                                                         %
FS(3).lb=1073;                                                                %
FS(3).ub=1081;                                                                %
FS(3).difflb=Inf;                                                             %
FS(3).diffub=Inf;                                                             %
FS(3).relerrlb=Inf;                                                           %
FS(3).relerrub=Inf;                                                           %
FS(3).nfeval=0;                                                               %
FS(3).vals=[];                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Flowshop 4%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS(4).P=[53 19 99 62 88 93 34 72 42 65 39 79  9 26 72 29 36 48 57 95;         %
 93 79 88 77 94 39 74 46 17 30 62 77 43 98 48 14 45 25 98 30;                 %
 90 92 35 13 75 55 80 67  3 93 54 67 25 77 38 98 96 20 15 36;                 %
 65 97 27 25 61 24 97 61 75 92 73 21 29  3 96 51 26 44 56 31;                 %
 64 38 44 46 66 31 48 27 82 51 90 63 85 36 69 67 81 18 81 72];                %
FS(4).mejorindividuo=[];                                                      %
FS(4).mejorval=Inf;                                                           %
FS(4).mejoresvals=[];                                                         %
FS(4).lb=1268;                                                                %
FS(4).ub=1293;                                                                %
FS(4).difflb=Inf;                                                             %
FS(4).diffub=Inf;                                                             %
FS(4).relerrlb=Inf;                                                           %
FS(4).relerrub=Inf;                                                           %
FS(4).nfeval=0;                                                               %
FS(4).vals=[];                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Flowshop 5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS(5).P=[61 86 16 42 14 92 67 77 46 41 78 3 72 95 53 59 34 66 42 63;          %
 27 92  8 65 34  6 42 39  2  7 85 32 14 74 59 95 48 37 59  4;                 %
 42 93 32 30 16 95 58 12 95 21 74 38  4 31 62 39 97 57  9 54;                 %
 13 47  6 70 19 97 41  1 57 60 62 14 90 76 12 89 37 35 91 69;                 %
 55 48 56 84 22 51 43 50 62 61 10 87 99 40 91 64 62 53 33 16];                %
FS(5).mejorindividuo=[];                                                      %
FS(5).mejorval=Inf;                                                           %
FS(5).mejoresvals=[];                                                         %
FS(5).lb=1198;                                                                %
FS(5).ub=1236;                                                                %
FS(5).difflb=Inf;                                                             %
FS(5).diffub=Inf;                                                             %
FS(5).relerrlb=Inf;                                                           %
FS(5).relerrub=Inf;                                                           %
FS(5).nfeval=0;                                                               %
FS(5).vals=[];                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Flowshop 6%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS(6).P=[71 27 55 90 11 18 42 64 73 95 22 53 32  5 94 12 41 85 75 38;         %
 13 11 73 43 27 33 57 42 71  3 11 49  8  3 47 58 23 79 99 23;                 %
 61 25 52 72 89 75 60 28 94 95 18 73 40 61 68 75 37 13 65  7;                 %
 21  8  5  8 58 59 85 35 84 97 93 60 99 29 94 41 51 87 97 11;                 %
 91 13  7 95 20 69 45 44 29 32 94 84 60 49 49 65 85 52  8 58];                %
FS(6).mejorindividuo=[];                                                      %
FS(6).mejorval=Inf;                                                           %
FS(6).mejoresvals=[];                                                         %
FS(6).lb=1180;                                                                %
FS(6).ub=1195;                                                                %
FS(6).difflb=Inf;                                                             %
FS(6).diffub=Inf;                                                             %
FS(6).relerrlb=Inf;                                                           %
FS(6).relerrub=Inf;                                                           %
FS(6).nfeval=0;                                                               %
FS(6).vals=[];                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Flowshop 7%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS(7).P=[15 64 64 48  9 91 27 34 42  3 11 54 27 30  9 15 88 55 50 57;         %
 28  4 43 93  1 81 77 69 52 28 28 77 42 53 46 49 15 43 65 41;                 %
 77 36 57 15 81 82 98 97 12 35 84 70 27 37 59 42 57 16 11 34;                 %
  1 59 95 49 90 78  3 69 99 41 73 28 99 13 59 47  8 92 87 62;                 %
 45 73 59 63 54 98 39 75 33  8 86 41 41 22 43 34 80 16 37 94];                %
FS(7).mejorindividuo=[];                                                      %
FS(7).mejorval=Inf;                                                           %
FS(7).mejoresvals=[];                                                         %
FS(7).lb=1226;                                                                %
FS(7).ub=1239;                                                                %
FS(7).difflb=Inf;                                                             %
FS(7).diffub=Inf;                                                             %
FS(7).relerrlb=Inf;                                                           %
FS(7).relerrub=Inf;                                                           %
FS(7).nfeval=0;                                                               %
FS(7).vals=[];                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Flowshop 8%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS(8).P=[34 20 57 47 62 40 74 94  9 62 86 13 78 46 83 52 13 70 40 60;         %
  5 48 80 43 34  2 87 68 28 84 30 35 42 39 85 34 36  9 96 84;                 %
 86 35  5 93 74 12 40 95 80  6 92 14 83 49 36 38 43 89 94 33;                 %
 28 39 55 21 25 88 59 40 90 18 33 10 59 92 15 77 31 85 85 99;                 %
  8 91 45 55 75 18 59 86 45 89 11 54 38 41 64 98 83 36 61 19];                %
FS(8).mejorindividuo=[];                                                      %
FS(8).mejorval=Inf;                                                           %
FS(8).mejoresvals=[];                                                         %
FS(8).lb=1170;                                                                %
FS(8).ub=1206;                                                                %
FS(8).difflb=Inf;                                                             %
FS(8).diffub=Inf;                                                             %
FS(8).relerrlb=Inf;                                                           %
FS(8).relerrub=Inf;                                                           %
FS(8).nfeval=0;                                                               %
FS(8).vals=[];                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Flowshop 9%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS(9).P=[37 36  1  4 64 74 32 67 73  7 78 64 98 60 89 49  2 79 79 53;         %
 59 16 90  3 76 74 22 30 89 61 39 15 69 57  9 13 71  2 34 49;                 %
 65 94 96 47 35 34 84  3 60 34 70 57  8 74 13 37 87 71 89 57;                 %
 70  3 43 14 26 83 26 65 47 94 75 30  1 71 46 87 78 76 75 55;                 %
 94 98 63 83 19 79 54 78 29  8 38 97 61 10 37 16 78 96  9 91];                %
FS(9).mejorindividuo=[];                                                      %
FS(9).mejorval=Inf;                                                           %
FS(9).mejoresvals=[];                                                         %
FS(9).lb=1206;                                                                %
FS(9).ub=1230;                                                                %
FS(9).difflb=Inf;                                                             %
FS(9).diffub=Inf;                                                             %
FS(9).relerrlb=Inf;                                                           %
FS(9).relerrub=Inf;                                                           %
FS(9).nfeval=0;                                                               %
FS(9).vals=[];                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Flowshop 10%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FS(10).P=[27 92 75 94 18 41 37 58 56 20  2 39 91 81 33 14 88 22 36 65;        %
 79 23 66  5 15 51  2 81 12 40 59 32 16 87 78 41 43 94  1 93;                 %
 22 93 62 53 30 34 27 30 54 77 24 47 39 66 41 46 24 23 68 50;                 %
 93 22 64 81 94 97 54 82 11 91 23 32 26 22 12 23 34 87 59  2;                 %
 38 84 62 10 11 93 57 81 10 40 62 49 90 34 11 81 51 21 39 27];                %
FS(10).mejorindividuo=[];                                                     %
FS(10).mejorval=Inf;                                                           %
FS(10).mejoresvals=[];                                                        %
FS(10).lb=1082;                                                               %
FS(10).ub=1108;                                                               %
FS(10).difflb=Inf;                                                            %
FS(10).diffub=Inf;                                                            %
FS(10).relerrlb=Inf;                                                          %
FS(10).relerrub=Inf;                                                          %
FS(10).nfeval=0;                                                              %
FS(10).vals=[];                                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%FS(i).stats%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Simular 25 veces por cada caso de prueba
%The study should be made with dimensions D = 50, D = 100, D=200, D=500, and D = 1,000. 
%The maximum number of fitness evaluations is 5,000·D. 
%Each run stops when the maximal number of evaluations is achieved.
%Calcular las siguientes medidas de desempeño
N = 30; %Simulaciones
generaciones=100;
NP=5*(20*5);%5*D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:10
  FS(i).stats.errslb = zeros(N,generaciones); %Acumula los errores respecto a la cota inferior 
  FS(i).stats.errsub = zeros(N,generaciones); %Acumula los errores respecto a la cota superior
  FS(i).stats.vals   = zeros(N,generaciones); 
  FS(i).stats.nfevals  = zeros(N,1);
  
  FS(i).statsSelectivo.errslb = zeros(N,generaciones); %Acumula los errores respecto a la cota inferior 
  FS(i).statsSelectivo.errsub = zeros(N,generaciones); %Acumula los errores respecto a la cota superior
  FS(i).statsSelectivo.vals   = zeros(N,generaciones); 
  FS(i).statsSelectivo.nfevals  = zeros(N,1);
  
  
  
  %FS(i).stats.avgerrlb = 0;% Error promedio respecto a la cota inferior
  %FS(i).stats.avgerrub = 0;% Error promedio respecto a la cota superior
  %FS(i).stats.maxerrlb = 0;% Error maximo respecto a la cota inferior
  %FS(i).stats.maxerrub = 0;% Error maximo respecto a la cota superior
  %FS(i).stats.minerrlb = 0;% Error minimo respecto a la cota inferior
  %FS(i).stats.minerrub = 0;% Error minimo respecto a la cota superior
  %FS(i).stats.mederrlb = 0;% Mediana del error respecto a la cota inferior
  %FS(i).stats.mederrub = 0;% Mediana del error respecto a la cota superior
end



for j=1:1 %Este for recorre los problemas (10)
  for i=1:N %Simulaciones
     [mejorindividuo, mejorval, nfeval, difflb, diffub, mejores]=EvoDif_Programa(FS(j),NP,generaciones,'Makespan',false);
     FS(j).stats.errlb(i)   = difflb;
     FS(j).stats.errub(i)   = diffub;
     FS(j).stats.vals(i,:)    = mejores;
     FS(j).stats.nfevals(i) = nfeval;
     
     [mejorindividuo, mejorval, nfeval, difflb, diffub, mejores]=EvoDif_Programa(FS(j),NP,generaciones,'Makespan', true);
     FS(j).statsSelectivo.errlb(i)   = difflb;
     FS(j).statsSelectivo.errub(i)   = diffub;
     FS(j).statsSelectivo.vals(i,:)    = mejores;
     FS(j).statsSelectivo.nfevals(i) = nfeval;
     %if mejorval<FS(j).mejorval
     %   FS(j).mejorval=mejorval;
     %   FS(j).mejorindividuo=mejorindividuo;
     %   FS(j).nfeval=nfeval;
     %   FS(j).difflb=difflb;
     %   FS(j).diffub=diffub;
     %   FS(j).vals=vals;
     %end
     
  end
  
  if 0
    %Plot del makespan promedio
    f=figure;
    set(f,'visible','off')
    titulo=sprintf('Taillard Flowshop (5x20) %d',j);
    plot(vals,'-.b')
    hold on;
    plot(mejores,'-ro')
    legend('Makespan promedio', 'Mejor makespan')
    title(titulo)
  
    xlabel('Generaciones')
    ylabel('Makespan')

    nombre = sprintf('TaillardFS_%d',j);
    saveas(f,nombre,'pdf');
    saveas(f,nombre,'fig');
     
      
    %Tabla de mejor individuo
    mejorindfile = sprintf('mejorind_%d',j); %nombre del archivo el mejor individuo
    FSJ=FS(j);
    save(mejorindfile,'mejorindividuo');

    %Tablas de datos
    datosfile = sprintf('datos_%d.mat',j);%nombre del archivo de los datos del problema
    save(datosfile,'-struct', 'FSJ');
   end
    %%%%%%%%%%%%%%%%%%%%%%%
   % FSJ=FS(j);
   % fprintf('\nLB\t\t\t\t\t\t\t %f\n',FSJ.lb)
   % fprintf('UB\t\t\t\t\t\t\t %f\n',FSJ.ub)
   % fprintf('Diferencia LB\t\t\t\t %f\n',FSJ.difflb)
   % fprintf('Diferencia UB\t\t\t\t %f\n',FSJ.diffub)
   % fprintf('Error relativo LB\t\t\t %f\n',FSJ.relerrlb)
   % fprintf('Error relativo UB\t\t\t %f\n',FSJ.relerrub)
   % fprintf('Mejor valor\t\t\t\t\t %f\n',FSJ.mejorval)
   % fprintf('Evaluaciones de la funcin\t %f\n',FSJ.nfeval)
      
    %FS(j).mejorindividuo
    %%Guardar errores
        
  %FS(j).stats.errslb(k)=FS(j).mejorval-FS(j).lb;
  %FS(j).stats.errsub(k)=FS(j).mejorval-FS(j).ub;
  figure;
  boxplot(FS(j).stats.vals, 1, '.',1,1);
  hold on;
  boxplot(FS(j).statsSelectivo.vals, 1, ['x','*'], 1, 1);
end

%%%%%Calcular Stats%%%%%%%%%%%
%for j=1:10
%  FS(j).stats.avgerrlb = mean(F(j).stats.errslb);
%  FS(j).stats.avgerrub = mean(F(j).stats.errsub);
%  FS(j).stats.maxerrlb = max(F(j).stats.errslb);
%  FS(j).stats.maxerrub = max(F(j).stats.errsub);
%  FS(j).stats.minerrlb = min(F(j).stats.errslb);
%  FS(j).stats.minerrub = min(F(j).stats.errsub);
%  FS(j).stats.mederrlb = median(F(j).stats.errslb);
%  FS(j).stats.mederrub = median(F(j).stats.errsub);
%  FSJ=FS(j);
%  fprintf('Error promedio LB:\t', FSJ.stats.avegerrlb)
%  fprintf('Error promedio UB:\t', FSJ.stats.avgerrub)
%  fprintf('Error maximo LB:\t', FSJ.stats.maxerrlb)
%  fprintf('Error maximo UB:\t', FSJ.stats.maxerrub)
%  fprintf('Error minimo LB:\t', FSJ.stats.minerrlb)
%  fprintf('Error minimo UB:\t', FSJ.stats.minerrub)
%  fprintf('Mediana de los errores LB:\t', FSJ.stats.mederrlb)
%  fprintf('Mediana de los errores UB:\t', FSJ.stats.mederrub)
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Simulación con transformacion de parametros aqui


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Comparar algoritmo con Evolucion diferencial simple con transformacion
%de parametros a parametros reales (Tengo un pdf con eso)

%Statistical analysis on the average error. 
%A comparision should be carried out by applying non-parametric tests, such as Wilcoxon's test and Holm's test. 
%General information and software on these tests may be found in the following link: http://sci2s.ugr.es/sicidm/. 
%See as well: 
%S. Garcia, D. Molina, M. Lozano, F. Herrera, 
%A study on the use of non-parametric tests for analyzing the evolutionary algorithms' behaviour: 
%a case study on the CEC'2005 Special Session on Real Parameter Optimization. 
%Journal of Heuristics 15 (2009) 617-644. doi: 10.1007/s10732-008-9080-4. (Pdf file).

%An analysis of the scalability behaviour of the proposed algorithms.
%An investigation of the computational running time of the algorithms. 
%Authors should provide, for each function, the average running time on the 25 runs. 
%In addition, the computational conditions (machine, programming language, compiler, etc.) 
%should be specified in the paper.
%In addition, authors should provide the following material:
%The source code of the algorithms. 
%The source codes of the algorithms will be published as complementary material to the special issue 
%(they will be available from an associated website).
%An Excel file having the performance measures achieved by the algorithms on every test problem.








