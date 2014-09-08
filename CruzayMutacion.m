function offspring=CruzayMutacion(p,m,M,N,NP,orden)
    %En la cruza se elige la información en común
    %entre ambos padres, se elige con proabilidad CR
    %a uno de los padres como "plantilla", y se permutan
    %las entradas distintas entre los padres.
    %se elige a uno de los padres como plantilla, pues 
    %cada padre representa un schedule, y elegir "mezclar"
    %las entradas distintas podría generar offsprings inválidos.
    offspring=p;
    if orden==false
        indx=(1:(M*N))'; %
        eq=(p==m);   %
        neq=1-eq;    %
        c=indx.*neq; %
        c(c==0)=[];%Eliminar los ceros
        %Aquí se puede utilizar CR
        %proba CR para el padre
        %y 1-CR para la madre, por ejemplo...
        offspring=p;
        %Aquí se permutan las entradas que son distintas
        %entre los padres
        %len=length(c)
        %if len>0
        offspring(c)=offspring(c(randperm(length(c))));    
        %end
        %size(offspring)
    else
        %Si el orden se toma en cuenta, no se permutan los trabajos
        %se sigue el mismo procedimiento mencionado arriba, pero para
        %cada trabajo, respetando el orden de los mismos
        p=reshape(p,M,N);
        m=reshape(m,M,N);
        offspring=reshape(offspring,M,N);
        %size(offspring)
        for i=1:N
            %i, size(p), size(m)
            offspring(:,i)==CruzayMutacion(p(:,i),m(:,i),M,1,NP,false);
        end
        offspring=offspring(:);
    end
end