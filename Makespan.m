function C=Makespan(O)%flow shop makespan
    %O=P;
    [M,N]=size(O);
    %for i=2:M
    %    O(i,1)=O(i,1)+O(i-1,1);
    %end
    %deltaC_ij=0;
    O(1,:)=cumsum(O(1,:));
    O(:,1)=cumsum(O(:,1));
    for j=2:N
        for i=2:M
            %deltaC_ij=sum(O(i-1,1:j))-sum(O(i,1:j-1));
            O(i,j)=O(i,j)+max(O(i-1,j),O(i,j-1));%+H(deltaC_ij);
        end
    end
   C=O(M,N);
end