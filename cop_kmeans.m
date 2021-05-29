function [labels, centres] = cop_kmeans(data,number_of_clusters, ...
    c_join, c_repel, maxIter, verbose)
%
% COP_KMEANS: Return the labels and centres of clusters applying 
% must-link and cannot-link constraints. 
%
% data is a numerical array of size N(objects)-by-n(features)
% c_join is an nML-by-2 array containing the indices of the pairs that 
%       must be in the same cluster
% c_repel is an nCL-by-2 array containing the indices of the pairs 
%       that cannot be in the same cluster.
% maxIter is the limit number of iterations of the k-means algorithm
% verbose is a flag to allow plot of 2D data (if set to 1)
%
% Usage:
%
%    [labels, centres] = cop_kmeans(data,number_of_clusters, ...
%        c_join, c_repel, maxIter, verbose)
%
% For the method, see
% [Wagstaff, K., Cardie, C., Rogers, S., & Schrödl, S., Constrained 
% k-means clustering with background knowledge. In ICML, Vol. 1, 2001, 
% pp. 577-584.]
% https://web.cse.msu.edu/~cse802/notes/ConstrainedKmeans.pdf
%
% Without input arguments, the function runs a demo example.

%========================================================================
% (c) L. Kuncheva                                                   ^--^
% 29.05.2021 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

% Run an example if no arguments are given --------------------------------
if nargin == 0
    close all % test run
    verbose = 1;
    T = 80;
    data = rand(T,2); % generate 2D data
    number_of_clusters = 4;
    nML = 8;
    nCL = 8;
    c_join = reshape(randperm(T,2*nML),nML,2);
    remaining = setxor(1:T,unique(c_join));
    c_repel = reshape(randperm(numel(remaining),2*nCL),nCL,2);
    c_repel = remaining(c_repel);
end

if nargin < 5
    maxIter = 10000;
end

N = size(data,1); % number of points to cluster
mind = randperm(N,number_of_clusters);
m = data(mind,:);
labels = zeros(N,1);

iter = 1;
flag = true; % convergence

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
                    new_labels,c_join,c_repel)
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
        %else
        %    labels = new_labels;
    end
    
    iter = iter + 1;
end

if verbose
    plot_2D_clusters(data, labels, number_of_clusters, c_join, c_repel)
end

centres = m;

end

% -------------------------------------------------------------------------
function out = check_validity_point(point_index,point_class, labels, ...
    c_join,c_repel)
out = true;

for i = 1:size(c_join,1)
    if c_join(i,1) == point_index && labels(c_join(i,2))~=point_class ...
            && labels(c_join(i,2))~= 0
        out = false;
        return
    elseif c_join(i,2) == point_index && ...
            labels(c_join(i,1))~=point_class && labels(c_join(i,1))~= 0
        out = false;
        return
    end
end

for i = 1:size(c_repel,1)
    if c_repel(i,1) == point_index && labels(c_repel(i,2))==point_class ...
            && labels(c_repel(i,2))~= 0
        out = false;
        return
    elseif c_repel(i,2) == point_index && ...
            labels(c_repel(i,1))==point_class && labels(c_repel(i,1))~= 0
        out = false;
        return
    end
end
end

function plot_2D_clusters(data,labels,number_of_clusters,...
    c_join, c_repel)

colours = jet(number_of_clusters);
figure, hold on, axis equal, grid on
if size(data,1) < 350
    % Works only for a small number of 2D data points
    for i = 1:number_of_clusters
        ind = labels == i;
        x = data(ind,1); y = data(ind,2);
        if numel(x) > 1
            pairs = nchoosek(1:numel(x),2);
            for j = 1:size(pairs,1)
                plot([x(pairs(j,1))';x(pairs(j,2))'],...
                    [y(pairs(j,1))';y(pairs(j,2))'],'k.-',...
                    'linewidth',0.5,'color',colours(i,:)*0.2+0.8)
            end
        end
    end
end
for i = 1:number_of_clusters
    
    ind = labels == i;
    x = data(ind,1); y = data(ind,2);
    
    plot(x,y,'k.','color',colours(i,:)*0.8,'markersize',15)
end

for i = 1:size(c_join,1)
    plot([data(c_join(i,1),1),data(c_join(i,2),1)],...
        [data(c_join(i,1),2),data(c_join(i,2),2)],'k-')
end
for i = 1:size(c_repel,1)
    plot([data(c_repel(i,1),1),data(c_repel(i,2),1)],...
        [data(c_repel(i,1),2),data(c_repel(i,2),2)],'k--')
end

end
