%========================================================================
% 2D doughnut clustering% 
% COP-kmeans and hierarchical clustering are applied with randomly 
% generated constraints of the type must-link (ML) and cannot-link (CL). 

% (c) L. Kuncheva                                                   ^--^
% 09/05/2022 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

clear, clc, close all

T = 200; % number of points to sample
s = 0.1; % sigma (std for the normal distribution)

x = sampling_from_hypersphere([0,0],0.5,T,s);
y = sampling_from_hypersphere([0,0],1,T,s);
data = [x;y];
labels = [ones(T,1);ones(T,1)*2];
shuffle_index = randperm(2*T);
data = data(shuffle_index,:);
labels = labels(shuffle_index);
nML = 6; nCL = 6;
[ML, CL] = create_random_links(nML, nCL, labels);


f = figure('Position',[100,100,1000,600]);

plot_clusters(f,241,data,ones(size(data,1),1),'original data')

labels1 = kmeans(data,2,'Maxiter',100);
plot_clusters(f,242,data,labels1,'kmeans')

labels2 = cop_kmeans(data,2, ML, CL, 100);
plot_clusters(f,243,data,labels2,'cop-kmeans')

seed_index = randperm(2*T,60);
seed_labels = labels(seed_index);
labels3 = constrained_kmeans(data, seed_index, seed_labels, 0);
plot_clusters(f,244,data,labels3,'seeded kmeans')

labels4 = constrained_kmeans(data, seed_index, seed_labels, 1);
plot_clusters(f,245,data,labels4,'constrained kmeans')

Z = linkage(data); % sinlge, euclidean
labels5 = cluster(Z,'maxclust',2);
plot_clusters(f,246,data,labels5,'single linkage')

labels6 = constrained_hierarchical(data,2, ML, CL);
plot_clusters(f,247,data,labels6,'constrained-hierarchical')

% ========================================================================

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

function x = sampling_from_hypersphere(centre,radius,N,sigma)

n = numel(centre); % data dimensionality
d = [rand(N,n-2) * pi, rand(N,1) * 2* pi]; % array with random directions
r = randn(N,n)*sigma; % random addition for each point
for i = 1:n-1
    x(:,i) = cos(d(:,i)).*prod(sin(d(:,1:i-1)),2);
end
x(:,n) = prod(sin(d),2);
    
x = radius*x + repmat(centre(:)',N,1) + r;

end

function plot_clusters(fig,subn,data,labels,titlestring)
figure(fig)
subplot(subn)
hold on
plot(data(labels==1,1),data(labels==1,2),'k.')
plot(data(labels==2,1),data(labels==2,2),'rx')
axis equal off
title(titlestring)
set(gca,'FontSize',10)
end