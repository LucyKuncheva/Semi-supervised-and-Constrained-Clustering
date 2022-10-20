function labels = constrained_kmeans(data,seed_index,...
    seed_labels, flag_constrained)

%=======================================================================
%kmeans_constrained Two variants of seeded constrained clustering
%   labels = kmeans_constrained(data,seed_index,seed_labels, ...
%            flag_constrained) 
%   Applies seeded k-means constrained clustering in two variants. 
%   In variant 1, the initial means are seeded by the data points chosen 
%   by seed_index. The whole data set is clustered by k-means while the
%   seed labels are ignored. In Variant 2, the seeding is the same, but the
%   seed labels are preserved during k-means.
%
%   Input -----
%      'data': N-by-n numerical array with N data points to cluster
%      'seed_index': a vector with indices of seed points in data
%      'seed_labels': class labels of the seed points
%      'flag_constrained': false for Variant 1 and true for Variant 2 
%
%   Output -----
%      'labels': assigned cluster labels
%
% For the method, see
% [Basu S., Banerjee A. & Mooney, R., Semi-supervised clustering by 
% seeding, Proc. of the 19th ICML, 2002, 19-26, doi 10.5555/645531.656012]
%========================================================================
% (c) L. Kuncheva                                                   ^--^
% 20.10.2022 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%


% The number of clusters is determined by the seed labels (assuming seed
% labels are integers - no need to be consecutive or to start with 1)
%
% flag_constrained = 1 for *Constrained* kmeans and 0 for *Seeded* kmeans


% Relabel the seeded part to 1,2, ... 
% Revert the labels later.
seed_labels = grp2idx(categorical(seed_labels));

% Initial means
unique_labels = unique(seed_labels);
me = grpstats(data(seed_index,:),seed_labels,"mean");

old_me = me-1; % old means

while any(old_me~=me)
    old_me = me;    
    e = pdist2(data,me);
    [~,labels] = min(e,[],2); % labels 

    % Constrained versus Seeded
    if flag_constrained 
        labels(seed_index) = seed_labels; % preserve the seed labels
    end

    nm = grpstats(data,labels,"mean"); % new means
    uc = unique(labels); % to avoid empty clusters - keep old means
    me(uc,:) = nm;
    
end
labels = unique_labels(labels);
