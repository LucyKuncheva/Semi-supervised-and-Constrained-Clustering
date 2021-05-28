%========================================================================
% Three data distributions are generated and displayed in figures: 
% a 2D doughnut, a 3D torus and a rod in the middle, and two interlocked 
% tori. 

% (c) L. Kuncheva                                                   ^--^
% 28.05.2021 -----------------------------------------------------  \oo/
% -------------------------------------------------------------------\/-%

clear, clc, close all

T = 2000; % number of points to sample
s = 0.1; % sigma (std for the normal distribution)

% Example 1: circles ------------------------------------------------------
x = sampling_from_hypersphere([0,0],0.5,T,s);
y = sampling_from_hypersphere([0,0],1,T,s);

figure, hold on, grid on, axis equal
plot(x(:,1),x(:,2),'k.')
plot(y(:,1),y(:,2),'k.')

% Example 2: torus and rod ------------------------------------------------
x = sampling_from_torus([0,0],1,T,s);
tz = rand(T,1)*2 - 1; txy = randn(T,2)*s; 
y = [txy tz];

figure, hold on, grid on, axis equal
plot3(x(:,1),x(:,2),x(:,3),'k.')
plot3(y(:,1),y(:,2),y(:,3),'k.')
rotate3d
view([23 17])

% Example 3: two toruses --------------------------------------------------
x = sampling_from_torus([0,0],1,T,s);
yy = sampling_from_torus([0,0],1,T,s);

% rotate about y-axis
theta = pi/2;
R = [cos(theta), 0, sin(theta);0 1 0;-sin(theta), 0, -cos(theta)];
y = yy*R';
y(:,2) = y(:,2) - 1; 

figure, hold on, grid on, axis equal
plot3(x(:,1),x(:,2),x(:,3),'k.')
plot3(y(:,1),y(:,2),y(:,3),'k.')
rotate3d
view([52 18])