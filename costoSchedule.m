function c=costoSchedule(J,M,N)
    %c: costo
    %r: rengl�n
    
    %N=length(M(:))/2;
    %M=reshape(M,N,N);
    %aqu� el costo es lo que se llama "carga"
    %m�xima de las m�quinas
    %http://www2.informatik.hu-berlin.de/alcox/lehre/lvws1011/coalg/makespan_scheduling.pdf
    J=reshape(J,M,N);
    c=max(sum(J,2));
end