function J = jaccard_index(A, B)
%=======================================================================
%jaccard_index.  Calculates the Jaccard index for matching two label sets.
%
%   J = jaccard_index(A, B)
%
%   Input -----
%      'A': candidate labels (integers)
%      'B': true labels (integers)
%
%   Output -----
%      'J': Jaccard index
%
%========================================================================

% (c) Lucy Kuncheva                                                 ^--^
% 20.07.2022 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

N = numel(A);
agreement = 0; Jaccard = 0;

for i = 1:N-1
    for j = i+1:N
        logicalA = A(i) == A(j);
        logicalB = B(i) == B(j);
        if  logicalA && logicalB % both in the same cluster
            Jaccard = Jaccard + 1;
        end
        if (logicalA && logicalB) || ((~logicalA) && (~logicalB))
            agreement = agreement + 1; % either in the same cluster 
            % of both in different clusters
        end
    end
end
total_pairs = N * (N - 1) / 2;
J = Jaccard / (total_pairs - agreement + Jaccard);
