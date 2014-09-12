function c=scheduleCost(J,M,N)
    J=reshape(J,M,N);
    %Jmax=repmat(max(J),M,1);
    %W = max(sum(Jmax-J,2));
	%c=max(sum(J,2));
    c=sum(max(J));
end
