function x = sampling_from_torus(centre,radius,N,sigma)
%
%SAMPLING_FROM_TORUS: Sample N points from a horizontal 3D torus. The 
%points have Normal distribution about the skeleton of the torus. Vector
%"centre" should contain two values for a 3D torus.
%
%   x = sampling_from_torus(centre,radius,N,sigma)
%
%  x is an array of size N-by-3

%========================================================================
% (c) L Kuncheva                                                    ^--^
% 28.05.2021 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

txy = sampling_from_hypersphere(centre,radius,N,sigma);
tz = randn(N,1) * sigma;
    
x = [txy tz];

