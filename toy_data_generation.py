# Library for generating toy data for clustering

#========================================================================
# (c) L. Kuncheva                                                   ^--^
# 28.05.2021 -----------------------------------------------------  \oo/
# -------------------------------------------------------------------\/-

import numpy as np

#-----------------------------------------------------------------------------
def sampling_from_hypersphere(centre = [0,0], radius = 3, N = 300, sigma = 1):

    # SAMPLING_FROM_HYPERSPHERE: Sample N points from an n-dimensional 
    # hypersphere with Normal distribution.
    # For the method, see https://en.wikipedia.org/wiki/N-sphere
    # (Spherical coordinates)

    n = len(centre); # data dimensionality
    d = np.random.random((N,n-1)) * np.pi 
    d[:,-1] = d[:,-1]*2  
    # array with random directions
    r = np.random.normal(size=(N,n))*sigma; # random addition for each point
    x = np.empty((N,n))
    for i in range(n-1):
        x[:,i] = np.cos(d[:,i])*np.prod(np.sin(d[:,:i-1]),axis=1)
    x[:,-1] = np.prod(np.sin(d),axis = 1)
    x = radius*x + centre + r
    return x
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
def sampling_from_torus(centre = [0,0], radius = 3, N = 300, sigma = 1):

    # SAMPLING_FROM_TORUS: Sample N points from a horizontal 3D torus. The 
    # points have Normal distribution about the skeleton of the torus. Vector
    # "centre" should contain two values for a 3D torus.
    # x is an array of size N-by-3

    txy = sampling_from_hypersphere(centre,radius,N,sigma)
    tz = np.random.normal(size=(N,1)) * sigma
    x = np.hstack((txy, tz))
    return x
#-----------------------------------------------------------------------------
