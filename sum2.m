function y = sum2(x)
% 
% Sum Squares function
% Matlab Code by A. Hedar (Nov. 23, 2005).
% The number of variables n should be adjusted below.
% The default value of n = 20.
% 
n = 2;
s = 0;
for j = 1:n  
    s=s+j*x(j)^2; 
end
y = s;
