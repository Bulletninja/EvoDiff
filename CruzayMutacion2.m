function offspring=CruzayMutacion2(p,m,M,N)
    %CR=0.1;
    %En la cruza se elige la informacin en comn
    %entre ambos padres, se elige con proabilidad CR
    %a uno de los padres como "plantilla", y se permutan
    %las entradas distintas entre los padres.
    %se elige a uno de los padres como plantilla, pues 
    %cada padre representa un schedule, y elegir "mezclar"
    %las entradas distintas podra generar offsprings invlidos.
    p=reshape(p,M,N);
    m=reshape(m,M,N);
    offspring=p;
    v=prod(double(p~=m));%1-prod(double(p==m),1);% 1 en los trabajos distintintamente ubicados
     %u=rand;
    %if u<CR
     %if u<CR
     %    p=rand(1,N)<CR;
     %    v=abs(p-v);
     %    v=~v;
     %end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%Esta parte permuta aleatoriamente los trabajos (columnas de la matriz)
 %%que no coinciden entre los padres del individuo actual
    indx=1:N; %
    c=indx.*v; %
    %d=indx.*(~v);
    %d(d==0)=[];
    c(c==0)=[];%Eliminar los ceros
    %if u<CR
        offspring(:,c)=offspring(:,c(randperm(length(c))));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %else
    %    offspring(:,d)=offspring(:,d(randperm(length(d))));
    %end
    %if u<CR
    %    offspring=circshift(offspring,[0 randi(N,1)]);
    %end
    offspring=offspring(:);
end
