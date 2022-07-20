function [nmi,vi] = normalised_mutual_information(A,B)
%=======================================================================
%normalised_mutual_information.  Calculates normalised mutual information
%and variation information between candidate labels and true labels.
%
%   [nmi, vi] = normalised_mutual_information(A,B) 
%   Calculated as NMI(A,B) = I(A,B)/sqrt(H(A)H(B))
%                 VI(A,B) = H(A) + H(B) - 2*I(A,B)
%
%   Input -----
%      'A': candidate labels (integers)
%      'B': true labels (integers)
%
%   Output -----
%      'nmi': normalised mutual information
%      'vi': variation information
%
% [Vinh09] Vinh et al., Information Theoretic Measures for Clusterings 
% Comparison: Is a Correction for Chance Necessary? Proceedings of the 
% 26th International Confreence on Machine Learning, Montreal, Canada, 
% 2009.
%
%========================================================================

% (c) Lucy Kuncheva                                                 ^--^
% 20.07.2022 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

N = numel(A);

uA = unique(A); % unique candidate labels
nA = numel(uA);

uB = unique(B); % unique true labels
nB = numel(uB);

tA = tabulate(A); tB = tabulate(B);
pA = tA(:,2)/N; pB = tB(:,2)/N; % distributions
indexA = pA > 0; indexB = pB > 0; 
HA = -sum(pA(indexA).*log(pA(indexA))); % entropies
HB = -sum(pB(indexB).*log(pB(indexB))); 

s = 0;
for i = 1:nA
    for j = 1:nB
        t = mean(A == uA(i) & B == uB(j)); % N_ij
        if t > 0 && pA(i) > 0 && pB(j) > 0
            s = s + t * log(t/(pA(i)*pB(j)));
        end
    end
end

nmi = s/sqrt(HA*HB);
vi = HA + HB - 2*s;
