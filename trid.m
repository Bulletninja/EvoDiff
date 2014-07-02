function  y = trid(x)
% 
% Trid function
% Matlab Code by A. Hedar (Nov. 23, 2005).
% The number of variables n should be adjusted below.
% The default value of n = 10.
% 
n = 2;
s1 = 0;
s2 = 0;
for j = 1:n;
    s1 = s1+(x(j)-1)^2;    
end
for j = 2:n;
    s2 = s2+x(j)*x(j-1);    
end
y = s1-s2;
