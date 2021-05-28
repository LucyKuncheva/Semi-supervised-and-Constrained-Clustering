#========================================================================
# Three data distributions are generated and displayed in figures: 
# a 2D doughnut, a 3D torus and a rod in the middle, and two interlocked 
# tori. 

# (c) L. Kuncheva                                                   ^--^
# 28.05.2021 -----------------------------------------------------  \oo/
# -------------------------------------------------------------------\/-

import matplotlib.pyplot as plt 
import numpy as np
import toy_data_generation as tdg

T = 2000 # number of points to sample
s = 0.1 # sigma (std for the normal distribution)

# ----------- Doughnut
x = tdg.sampling_from_hypersphere([0,0],0.5,T,s)
y = tdg.sampling_from_hypersphere([0,0],1,T,s)

plt.figure()
plt.plot(x[:,0],x[:,1],'k.', ms = 4)
plt.plot(y[:,0],y[:,1],'k.', ms = 4)
plt.axis('Equal')

# ----------- Torus and rod
x = tdg.sampling_from_torus([0,0],1,T,s)
tz = np.random.random(size = (T,1))*2 - 1; txy = np.random.normal(size = (T,2))*s 
y = np.hstack((txy, tz))

plt.figure()
ax = plt.axes(projection='3d')
ax.plot3D(x[:,0],x[:,1],x[:,2],'k.', ms = 2)
ax.plot3D(y[:,0],y[:,1],y[:,2],'k.', ms = 2)
ax.set_zlim3d([-1,1])

# ----------- Two tori
x = tdg.sampling_from_torus([0,0],1,T,s)
yy = tdg.sampling_from_torus([0,0],1,T,s)

# rotate about y-axis
theta = np.pi/2
R = [[np.cos(theta), 0, np.sin(theta)], \
    [0, 1, 0],[-np.sin(theta), 0, -np.cos(theta)]]
y = np.dot(yy,R)
y[:,1] = y[:,1] - 1 

plt.figure()
ax = plt.axes(projection='3d')
ax.plot3D(x[:,0],x[:,1],x[:,2],'k.', ms = 2)
ax.plot3D(y[:,0],y[:,1],y[:,2],'k.', ms = 2)
ax.set_ylim3d([-2,1])

plt.show()