function [J]=permutarTrabajos(J)%,orden)   
    %Cuando se toma en cuenta el orden de los trabajos
    %solamente se permutan las operaciones
    %y se supone que se reciben los trabajos en orden
%     if orden==true
%         J=reshape(J,M,N);
%         for i=1:N
%             J(:,i)=J(randperm(M),i);
%         end
%         J=J(:);
%     else
%       J=J(randperm(M*N));
%     end    
    %J=reshape(J,M,N);
    N=size(J,2);
    J=J(:,randperm(N));
    J=J(:);
end
     