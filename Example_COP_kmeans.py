#========================================================================
# Three data distributions are generated: a 2D doughnut, a 3D torus and a 
# rod in the middle, and two interlocked tori. COP-kmeans is applied to
# cluster each data set into two clusters with randomly generated of the 
# type must-link (c_join) and cannot-link (c_repel). 

# (c) L. Kuncheva                                                   ^--^
# 28.05.2021 -----------------------------------------------------  \oo/
# -------------------------------------------------------------------\/-%

import matplotlib.pyplot as plt 
import numpy as np
import toy_data_generation as tdg
import cop_kmeans as ck

def create_random_links(nML, nCL, labels):

    # pick must-link pairs
    ind1 = np.where(labels == 0)
    ind1 = ind1[0]
    p1 = np.random.permutation(len(ind1))-1
    p1 = p1[:nML]
    c_join = np.reshape(ind1[p1],(nML//2,2))

    ind2 = np.where(labels == 1)
    ind2 = ind2[0]
    p2 = np.random.permutation(len(ind2))-1
    p2 = p2[:nML]
    c_join = np.vstack((c_join,np.reshape(ind2[p2],(nML//2,2))))

    # pick cannot-link pairs
    ind1 = np.where(labels == 0)
    ind1 = ind1[0]
    p1 = np.random.permutation(len(ind1))
    p1 = p1[:nCL]
    ind2 = np.where(labels == 1)
    ind2 = ind2[0]    
    p2 = np.random.permutation(len(ind2))
    p2 = p2[:nCL]
    c_repel = np.hstack((ind1[p1],ind2[p2]))
    c_repel = np.reshape(c_repel,(2,nCL))
    c_repel = np.transpose(c_repel)
    
    return c_join, c_repel

#------------------------------------------------------------------------
def plot_3D_clusters(data, labels, number_of_clusters, c_join, c_repel):
    import matplotlib.pyplot as plt
    import numpy as np
    colours = np.random.rand(number_of_clusters,3)
    plt.figure()
    ax = plt.axes(projection='3d')
    if len(data) < 350:
        # Works only for a small number of 2D data points
        for i in range(number_of_clusters):
            ind = np.where(labels == i)
            ind = ind[0]
            x = data[ind,0]; y = data[ind,1]; z = data[ind,2]
            if len(x) > 1:
                for j1 in range(len(x)-1):
                    for j2 in range(j1,len(x)):
                        ax.plot3D([x[j1],x[j2]], \
                            [y[j1],y[j2]], \
                            [z[j1],z[j2]], \
                            'k.-',linewidth=1, \
                                color = colours[i,:]*0.2+0.8)
    for i in range(number_of_clusters):
        ind = np.where(labels == i)
        ind = ind[0]
        x = data[ind,0]; y = data[ind,1]; z = data[ind,2]
        ax.plot3D(x,y,z,'k.', color=colours[i,:]*0.8, ms = 8)

    for i in range(len(c_join)):
        ax.plot3D([data[c_join[i,0],0],data[c_join[i,1],0]], \
            [data[c_join[i,0],1],data[c_join[i,1],1]], \
            [data[c_join[i,0],2],data[c_join[i,1],2]], \
                'ko-',lw = 0.8)

    for i in range(len(c_repel)):
        ax.plot3D([data[c_repel[i,0],0],data[c_repel[i,1],0]], \
            [data[c_repel[i,0],1],data[c_repel[i,1],1]], \
            [data[c_repel[i,0],2],data[c_repel[i,1],2]], \
            'ko--',lw = 0.8,markerfacecolor='none')

    plt.show()
# ===========================================================================

T = 500 # number of points to sample
s = 0.1 # sigma (std for the normal distribution)

# Example 1: circles ------------------------------------------------------
x = tdg.sampling_from_hypersphere([0,0],0.5,T,s)
y = tdg.sampling_from_hypersphere([0,0],1,T,s)

data = np.vstack((x,y))
labels = np.vstack((np.zeros((T,1)),np.ones((T,1))))
shuffle_index = np.random.permutation(2*T)-1
data = data[shuffle_index]
labels = labels[shuffle_index]
nML, nCL = 10, 10 
# nML must be even because we pick the same numbers from each cluster
c_join, c_repel = create_random_links(nML, nCL, labels)
ck.cop_kmeans(data = data,number_of_clusters = 2, c_join = c_join, \
    c_repel = c_repel, verbose = 1)

# Example 2: torus and rod ------------------------------------------------
x = tdg.sampling_from_torus([0,0],1,T,s)
tz = np.random.random(size = (T,1))*2 - 1; txy = np.random.normal(size = (T,2))*s 
y = np.hstack((txy, tz))

data = np.vstack((x,y))
labels = np.vstack((np.zeros((T,1)),np.ones((T,1))))
shuffle_index = np.random.permutation(2*T)-1
data = data[shuffle_index]
labels = labels[shuffle_index]
nML, nCL = 10, 10 
# nML must be even because we pick the same numbers from each cluster
c_join, c_repel = create_random_links(nML, nCL, labels)
assigned_labels,_ = ck.cop_kmeans(data = data, \
    number_of_clusters = 2, c_join = c_join, \
    c_repel = c_repel, verbose = 0)
plot_3D_clusters(data, assigned_labels, 2, c_join, c_repel)

# ----------- Two tori
x = tdg.sampling_from_torus([0,0],1,T,s)
yy = tdg.sampling_from_torus([0,0],1,T,s)

# rotate about y-axis
theta = np.pi/2
R = [[np.cos(theta), 0, np.sin(theta)], \
    [0, 1, 0],[-np.sin(theta), 0, -np.cos(theta)]]
y = np.dot(yy,R)
y[:,1] = y[:,1] - 1 

data = np.vstack((x,y))
labels = np.vstack((np.zeros((T,1)),np.ones((T,1))))
shuffle_index = np.random.permutation(2*T)-1
data = data[shuffle_index]
labels = labels[shuffle_index]
nML, nCL = 10, 10 
# nML must be even because we pick the same numbers from each cluster
c_join, c_repel = create_random_links(nML, nCL, labels)
ck.cop_kmeans(data = data,number_of_clusters = 2, c_join = c_join, \
    c_repel = c_repel, verbose = 0)

assigned_labels,_ = ck.cop_kmeans(data = data, \
    number_of_clusters = 2, c_join = c_join, \
    c_repel = c_repel, verbose = 0)
plot_3D_clusters(data, assigned_labels, 2, c_join, c_repel)