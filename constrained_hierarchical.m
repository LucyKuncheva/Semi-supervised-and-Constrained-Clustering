function labels = constrained_hierarchical(data,...
    number_of_clusters, c_join, c_repel, ~, verbose)
%
% CONSTRAINED_HIERARCHICAL: Return the labels of clusters applying
% must-link and cannot-link constraints.
%
% data is a numerical array of size N(objects)-by-n(features)
% c_join is an nML-by-2 array containing the indices of the pairs that
%       must be in the same cluster
% c_repel is an nCL-by-2 array containing the indices of the pairs
%       that cannot be in the same cluster.
% verbose is a flag to allow plot of 2D data (if set to 1)
%
% Usage:
%
%    labels = constrained_hierarchical(data,...
%                number_of_clusters, c_join, c_repel,[], verbose)
%
% For the method, see
% [Davidson I. & Ravi, S.S, Agglomerative Hierarchical Clustering with
% Constraints: Theoretical and Empirical Results, Proceedings of the
% 9th European Conference on Principles and Practice of Knowledge
% Discovery in Databases (PKDD), Porto, Portugal, October 3-7, 2005,
% LNAI 3721, Springer, 59-70.
% https://link.springer.com/content/pdf/10.1007/11564126_11.pdf
%
% Without input arguments, the function runs a demo example.

%========================================================================
% (c) L. Kuncheva                                                   ^--^
% 14.06.2021 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

% Run an example if no arguments are given --------------------------------
if nargin == 0
    rng(2012)
    close all % test run
    verbose = 1;
    T = 80;
    data = rand(T,2); % generate 2D data
    number_of_clusters = 4;
    nML = 8;
    nCL = 8;
    %c_join = reshape(randperm(T,2*nML),nML,2);
    c_join = randi(T,nML,2);
    %remaining = setxor(1:T,unique(c_join));
    %c_repel = reshape(randperm(numel(remaining),2*nCL),nCL,2);
    %c_repel = remaining(c_repel);
    c_repel = randi(T,nCL,2);
    
end

ML = c_join;
CL = c_repel;

N = size(data,1); % number of points to cluster

% 1. Construct the transitive closure of the ML constraints
if ~isempty(ML)
    G = digraph([ML(:,1);ML(:,2)],[ML(:,2);ML(:,1)]);
    labelsX = conncomp(G);
    
    maxML = max(ML(:)); % there will be no labels assigned to points after
    maxLabel = max(labelsX);
    labelsX(maxML + 1:N) = maxLabel + (1:N-maxML);
else
    labelsX = (1:N)';
end
% Relabel to order
labels = double(cmunique(labelsX)) + 1;
labels = labels(:);

% 2. If two points {x, y} are both a CL and ML constraint then output
% "No Solution" and stop.

for i = 1:size(CL,1)
    if labels(CL(i,1)) == labels(CL(i,2))
        disp('No solution')
        labels = [];
        t = 0;
        return
    end
end

% 4. Construct an initial feasible clustering with kmax clusters
% consisting of the r clusters M1,..., Mr and a singleton cluster
% for each point in S1. Set t = kmax

% 5. While (there exists a pair of mergeable clusters) do

labels = kruskals_mst_constrained(data,labels,number_of_clusters,CL);

if verbose
    plot_2D_clusters(data, labels, max(labels), c_join, c_repel)
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
                    [y(pairs(j,1))';y(pairs(j,2))'],'k-',...
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

function a = kruskals_mst_constrained(b,labels,c,CL)
% Kruskal’s algorithm (1956) MINIMUM SPANNING TREE
% 1.    Create a forest F (a set of trees), where each vertex in
%       in the graph is a separate tree
% 2.    Create a set S containing all the edges in the graph
% 3.    While S is nonempty and F is not yet spanning
%       a.  Remove an edge with minimum weight from S
%       b.  If that edge connects two different trees, then add
%           it to the forest, combining two trees into a single tree
%       c.  Otherwise discard that edge.
% 4.    At the termination of the algorithm, the forest forms
%       a minimum spanning forest of the graph. If the graph is
%       connected, the forest has a single component and forms a
%       minimum spanning tree.

d = size(b,1); % number of points
e = nchoosek(1:d,2); % array with all edges (d*(d-1)/2 rows, 2 columns)
f = b(e(:,1),:) - b(e(:,2),:); % differences between point
%                                coordinates (these will be
%                                squared later to get the
%                                squared distances)
[~,g] = sort(sum(f.*f,2)); % g is the index which will sort the
%                            edges from shortest to longest
e = e(g,:); % sorted edges according to length
% a = 1:d; % forest with d trees (returned labels)
a = labels;
while numel(unique(a)) > c % check if the desired number of clusters
    %                        has been reached;
    %                        if not, go through the loop
    
    if a(e(1,1)) ~= a(e(1,2)) % if the vertices of the shortest
        %                       remaining edge are NOT in the same
        %                       cluster,
        % Check validity
        if ~isempty(CL)
            temp = a;
            temp(temp == temp(e(1,1))) = temp(e(1,2));
            valid = ~any(temp(CL(:,1)) == temp(CL(:,2)));
            if valid
                a(a==a(e(1,1))) = a(e(1,2)); % relabel all vertices from
                %                              cluster 1 into cluster 2
                %                              (This eliminates cluster 1.)
            end
        else
            a(a==a(e(1,1))) = a(e(1,2)); % relabel all vertices from
            %                              cluster 1 into cluster 2
            %                              (This eliminates cluster 1.)
        end
    end
    e(1,:) = []; % remove the shortest edge after use
end
a = double(cmunique(a)) + 1; % as the labels for the c clusters may be
%                      any integers between 1 and d, "squeeze"
%                      them to be consecutive numbers 1, 2, 3,..., c

end

