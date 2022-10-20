function [labels, centres] = cop_kmeans(data,number_of_clusters, ...
    ML, CL, maxIter, initial_means)
%
% COP_KMEANS: Returns the labels and centres of clusters applying 
% must-link and cannot-link constraints. 
%
% data: a numerical array of size N(objects)-by-n(features)
% ML is an nML-by-2 array containing the indices of the pairs that 
%       must be in the same cluster
% CL: an nCL-by-2 array containing the indices of the pairs 
%       that cannot be in the same cluster.
% maxIter: the limit number of iterations of the k-means algorithm;
%       default = 1000
% initial_means: an array of size number_of_clusters-by-n with initial
%       means. If not specified, random rows of data are used instead 
%
% For the method, see
% [Wagstaff, K., Cardie, C., Rogers, S., & Schrödl, S., Constrained 
% k-means clustering with background knowledge. In ICML, Vol. 1, 2001, 
% pp. 577-584.]
% https://web.cse.msu.edu/~cse802/notes/ConstrainedKmeans.pdf
%

%========================================================================
% (c) L. Kuncheva                                                   ^--^
% 20.10.2022 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

if nargin < 5
    maxIter = 1000;
end

N = size(data,1); % number of points to cluster

% Initial means
if nargin < 6
    mind = randperm(N,number_of_clusters);
    m = data(mind,:);
else
    m = initial_means;
end
    
labels = zeros(N,1);

iter = 1;
flag = true; % not converged

while (iter < maxIter) && flag
    
    new_labels = zeros(N,1);
    
    % Re-label the data in feasible clusters
    for i = 1:N
        di = pdist2(data(i,:),m);
        [~,isorted] = sort(di);
        
        j = 1; % cluster index
        not_done = true;
        while j <= number_of_clusters && not_done
            if check_validity_point(i,isorted(j),...
                    new_labels,ML,CL)
                new_labels(i) = isorted(j);
                not_done = false;
            end
            j = j + 1;
        end
        if ~new_labels(i)
            disp('Impossible clustering.')
            labels = [];
            centres = [];
            return
        else
            labels(i) = new_labels(i);
        end
    end
    % Recalculate the means
    old_means = m;
    m = zeros(number_of_clusters,size(data,2));
    for inm = 1:number_of_clusters
        m(inm,:) = mean(data(new_labels == inm,:),1);
    end
    if all(old_means == m)
        flag = false;
    end
    
    iter = iter + 1;
end

centres = m;

end

% -------------------------------------------------------------------------
function out = check_validity_point(point_index,point_class, labels, ...
    ML,CL)
out = true;

for i = 1:size(ML,1)
    if ML(i,1) == point_index && labels(ML(i,2))~=point_class ...
            && labels(ML(i,2))~= 0
        out = false;
        return
    elseif ML(i,2) == point_index && ...
            labels(ML(i,1))~=point_class && labels(ML(i,1))~= 0
        out = false;
        return
    end
end

for i = 1:size(CL,1)
    if CL(i,1) == point_index && labels(CL(i,2))==point_class ...
            && labels(CL(i,2))~= 0
        out = false;
        return
    elseif CL(i,2) == point_index && ...
            labels(CL(i,1))==point_class && labels(CL(i,1))~= 0
        out = false;
        return
    end
end
end
