%========================================================================
% Three data distributions are generated: a 2D doughnut, a 3D torus and a 
% rod in the middle, and two interlocked tori. COP-kmeans is applied to
% cluster each data set into two clusters with randomly generated of the 
% type must-link (c_join) and cannot-link (c_repel). 

% (c) L. Kuncheva                                                   ^--^
% 28.05.2021 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

clear, clc, close all

T = 500; % number of points to sample
s = 0.1; % sigma (std for the normal distribution)
k = 10; % number per class

% Example 1: circles ------------------------------------------------------
x = sampling_from_hypersphere([0,0],0.5,T,s);
y = sampling_from_hypersphere([0,0],1,T,s);
data = [x;y];
labels = [ones(T,1);ones(T,1)*2];
shuffle_index = randperm(2*T);
data = data(shuffle_index,:);
labels = labels(shuffle_index);
nML = 10; nCL = 10;
[c_join, c_repel] = create_random_links(nML, nCL, labels);
cop_kmeans(data,2, c_join, c_repel, 1000, 1);

% Example 2: torus and rod ------------------------------------------------
x = sampling_from_torus([0,0],1,T,s);
tz = rand(T,1)*2 - 1; txy = randn(T,2)*s; 
y = [txy tz];
data = [x;y];
labels = [ones(T,1);ones(T,1)*2];
shuffle_index = randperm(2*T);
data = data(shuffle_index,:);
labels = labels(shuffle_index);
nML = 4; nCL = 4;
[c_join, c_repel] = create_random_links(nML, nCL, labels);
assigned_labels = cop_kmeans(data,2, c_join, c_repel, 1000, 0);
plot_3D_clusters(data,assigned_labels, 2, c_join, c_repel)
rotate3d
view([23 17])

% Example 3: two tori -----------------------------------------------------
x = sampling_from_torus([0,0],1,T,s);
yy = sampling_from_torus([0,0],1,T,s);

% rotate about y-axis
theta = pi/2;
R = [cos(theta), 0, sin(theta);0 1 0;-sin(theta), 0, -cos(theta)];
y = yy*R';
y(:,2) = y(:,2) - 1; 
data = [x;y];
labels = [ones(T,1);ones(T,1)*2];
shuffle_index = randperm(2*T);
data = data(shuffle_index,:);
labels = labels(shuffle_index);
nML = 4; nCL = 4;
[c_join, c_repel] = create_random_links(nML, nCL, labels);
assigned_labels = cop_kmeans(data,2, c_join, c_repel, 1000, 0);
plot_3D_clusters(data,assigned_labels, 2, c_join, c_repel)
rotate3d
view([23 17])

function [c_join, c_repel] = create_random_links(nML, nCL, labels)

% pick must-link pairs
ind1 = find(labels == 1);
p1 = randperm(numel(ind1),nML);
c_join = reshape(ind1(p1),nML/2,2);
ind2 = find(labels == 2);
p2 = randperm(numel(ind2),nML);
c_join = [c_join;reshape(ind2(p2),nML/2,2)];

% pick cannot-link pairs
p1 = randperm(numel(ind1),nCL);
p2 = randperm(numel(ind2),nCL);
c_repel = [ind1(p1(:)),ind2(p2(:))];
end

function plot_3D_clusters(data,labels,number_of_clusters,...
    c_join, c_repel)

colours = jet(number_of_clusters);
figure, hold on, axis equal, grid on
if size(data,1) < 350
    % Works only for a small number of 2D data points
    for i = 1:number_of_clusters
        ind = labels == i;
        x = data(ind,1); y = data(ind,2); z = data(ind,3);
        if numel(x) > 1
            pairs = nchoosek(1:numel(x),2);
            for j = 1:size(pairs,1)
                plot3([x(pairs(j,1))';x(pairs(j,2))'],...
                    [y(pairs(j,1))';y(pairs(j,2))'],...
                    [z(pairs(j,1))';z(pairs(j,2))'],'k.-',...
                    'linewidth',0.5,'color',colours(i,:)*0.2+0.8)
            end
        end
    end
end
for i = 1:number_of_clusters    
    ind = labels == i;
    x = data(ind,1); y = data(ind,2); z = data(ind,3);  
    plot3(x,y,z,'k.','color',colours(i,:)*0.8,'markersize',15)
end

for i = 1:size(c_join,1)
    plot3([data(c_join(i,1),1),data(c_join(i,2),1)],...
        [data(c_join(i,1),2),data(c_join(i,2),2)],...
        [data(c_join(i,1),3),data(c_join(i,2),3)],'k-')
end
for i = 1:size(c_repel,1)
    plot3([data(c_repel(i,1),1),data(c_repel(i,2),1)],...
        [data(c_repel(i,1),2),data(c_repel(i,2),2)],...
        [data(c_repel(i,1),3),data(c_repel(i,2),3)],'k--')
end

end
