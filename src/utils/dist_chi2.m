% Chi^2 histogram distance. A,B are matrices of example data
% vectors, one per column. The distance is sum_i
% (u_i-v_i)^2/(u_i+v_i+epsilon). The output distance matrix is
% (#examples in A)x(#examples in B)

function D = dist_chi2(A,B,epsilon)

if nargin<3, epsilon=1e-100; end
[d,m]=size(A);
[d1,n]=size(B);
if (d ~= d1)
    error('column length of A (%d) != column length of B (%d)\n',d,d1);
end

% With the MATLAB JIT compiler the trivial implementation turns out
% to be the fastest, especially for large matrices.
D = zeros(m,n);
for i=1:m % m is number of samples of A 
    for j=1:n % n is number of samples of B
        D(i,j) = sum((A(:,i)-B(:,j)).^2./(A(:,i)+B(:,j)+epsilon));
    end
end
%end
