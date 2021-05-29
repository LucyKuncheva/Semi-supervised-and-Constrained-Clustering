# COP_KMEANS: Return the labels and centres of clusters applying 
# must-link and cannot-link constraints. 
#
# data is a numerical array of size N(objects)-by-n(features)
# c_join is an nML-by-2 array containing the indices of the pairs that 
#       must be in the same cluster
# c_repel is an nCL-by-2 array containing the indices of the pairs 
#       that cannot be in the same cluster.
# maxIter is the limit number of iterations of the k-means algorithm
# verbose is a flag to allow plot of 2D data (if set to 1)
#
# Usage:
#
#    labels, centres = cop_kmeans(data,number_of_clusters, ...
#        c_join, c_repel, maxIter, verbose)
#
# For the method, see
# [Wagstaff, K., Cardie, C., Rogers, S., & Schrödl, S., Constrained 
# k-means clustering with background knowledge. In ICML, Vol. 1, 2001, 
# pp. 577-584.]
# https://web.cse.msu.edu/~cse802/notes/ConstrainedKmeans.pdf
#
# Without input arguments, the function runs a demo example.
#
#========================================================================
# (c) L. Kuncheva                                                   ^--^
# 29.05.2021 -----------------------------------------------------  \oo/
# -------------------------------------------------------------------\/-%

def cop_kmeans(data = [], number_of_clusters=[], c_join=[], c_repel=[], \
    maxIter = 1000, verbose = 0):
    import numpy as np

    if len(data) == 0:
        print('Running an example')
        verbose = 1
        T = 80
        data = np.random.rand(T,2) # generate 2D data
        number_of_clusters = 4
        nML, nCL = 8, 8 # number of ML and CL constraints
        to_join = np.random.permutation(T) - 1
        c_join = np.reshape(to_join[:2*nML],(nML,2))
        remaining = np.setdiff1d(range(T),np.unique(c_join))     
        to_repel = np.random.permutation(len(remaining)) - 1
        c_repel = np.reshape(to_repel[:2*nCL],(nCL,2))    
        c_repel = remaining[c_repel]
    
    N = len(data) # number of points to cluster

    # Pick the initial means
    mind = np.random.permutation(N)-1
    m = data[mind[:number_of_clusters],:]

    # Set initial labels to zero
    labels = np.zeros(N)


    iter = 1
    flag = True # convergence

    while (iter < maxIter) & flag:   
        new_labels = -np.ones(N) # labels for this iteration
    
        # Re-label the data in feasible clusters
        for i in range(N):
            # No pdist 2 command in Python :/
            di = np.sum((data[i,:] - m)**2, axis = 1)
            isorted = np.argsort(di) # index of sorted distances

            j = 0 # % cluster index (Python style; starting from 0)
            not_done = True # label for object i has not been found
            while (j < number_of_clusters) & not_done:

                if check_validity_point(i, isorted[j], \
                    new_labels,c_join,c_repel):
                    # Label is acceptable
                    new_labels[i] = isorted[j]
                    not_done = False
                j += 1
            
            if new_labels[i] == -1:
                # We did not find a feasible label for object i
                print('Impossible clustering.')
                return [], [] # empty labels and centres
            else:
                labels[i] = new_labels[i]
            
        # Recalculate the means
        old_means = m
        m = np.zeros((number_of_clusters,len(data[0])))
        for inm in range(number_of_clusters):
            m[inm,:] = np.mean(data[new_labels == inm,:],axis = 0)
        
        if np.all(old_means == m):
            flag = False
        iter +=1   

    if verbose:
        plot_2D_clusters(data, labels, number_of_clusters, c_join, c_repel)

    return labels, m # return labels and centres

#------------------------------------------------------------------------
def check_validity_point(point_index,point_class, labels, c_join,c_repel):
    out = True
    for i in range(len(c_join)):

        if (c_join[i,0] == point_index) & (labels[c_join[i,1]] != point_class) \
                & (labels[c_join[i,1]] != -1):
            out = False
            return out
        elif (c_join[i,1] == point_index) & (labels[c_join[i,0]] != \
            point_class) & (labels[c_join[i,0]] != -1):
            out = False
            return out

    for i in range(len(c_repel)):
        if (c_repel[i,0] == point_index) & (labels[c_repel[i,1]] == point_class) \
                & (labels[c_repel[i,1]] != -1):
            out = False
            return out
        elif (c_repel[i,1] == point_index) & (labels[c_repel[i,0]] == \
                point_class) & (labels[c_repel[i,0]] != -1):
            out = False
            return out
    return out

#------------------------------------------------------------------------
def plot_2D_clusters(data, labels, number_of_clusters, c_join, c_repel):
    import matplotlib.pyplot as plt
    import numpy as np
    colours = np.random.rand(number_of_clusters,3)
    plt.figure()
    plt.axis('Equal')
    plt.grid('On')
    if len(data) < 350:
        # Works only for a small number of 2D data points
        for i in range(number_of_clusters):
            ind = np.where(labels == i)
            ind = ind[0]
            x = data[ind,0]; y = data[ind,1]
            if len(x) > 1:
                for j1 in range(len(x)-1):
                    for j2 in range(j1,len(x)):
                        plt.plot([x[j1],x[j2]], \
                            [y[j1],y[j2]], \
                            'k.-',linewidth=1, \
                                color = colours[i,:]*0.2+0.8)
    for i in range(number_of_clusters):
        ind = np.where(labels == i)
        ind = ind[0]
        x = data[ind,0]; y = data[ind,1]
        plt.plot(x,y,'k.', color=colours[i,:]*0.8, ms = 8)

    for i in range(len(c_join)):
        plt.plot([data[c_join[i,0],0],data[c_join[i,1],0]], \
            [data[c_join[i,0],1],data[c_join[i,1],1]],'k-',lw = 0.8)

    for i in range(len(c_repel)):
        plt.plot([data[c_repel[i,0],0],data[c_repel[i,1],0]], \
            [data[c_repel[i,0],1],data[c_repel[i,1],1]],'k--',lw = 0.8)

    plt.show()

