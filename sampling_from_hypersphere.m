function x = sampling_from_hypersphere(centre,radius,N,sigma)
%
%SAMPLING_FROM_HYPERSPHERE: Sample N points from an n-dimensional 
%hypersphere with Normal distribution.
%
%   x = sampling_from_hypersphere(centre,radius,N,sigma)
%
%  x is an array of size N-by-numel(centre)

%========================================================================
% (c) L. Kuncheva                                                   ^--^
% 28.05.2021 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

n = numel(centre); % data dimensionality
d = [rand(N,n-2) * pi, rand(N,1) * 2* pi]; % array with random directions
r = randn(N,n)*sigma; % random addition for each point
for i = 1:n-1
    x(:,i) = cos(d(:,i)).*prod(sin(d(:,1:i-1)),2);
end
x(:,n) = prod(sin(d),2);
    
x = radius*x + repmat(centre(:)',N,1) + r;

