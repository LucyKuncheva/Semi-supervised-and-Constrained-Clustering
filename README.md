# Semi-supervised-and-Constrained-Clustering

File `ConstrainedClusteringReferences.pdf` contains a reference list related to [publication](https://arxiv.org/abs/2209.11125):

```
@misc{Kuncheva22,
author = {Ludmila I Kuncheva and Francis J Williams and Samuel L Hennessey},
title = {A Bibliographic View on Constrained Clustering},
year = {2022},
journal = {arXiv:2209.11125},
url = {https://arxiv.org/abs/2209.11125}
}
```

The repository contains code for semi-supervised learning and constrained clustering. 

- `cop_kmeans.m` is MATLAB implementation of the COP-kmeans algorithm from 

[[1]. Wagstaff, K., Cardie, C., Rogers, S., & Schrödl, S., Constrained k-means clustering with background knowledge. In ICML, Vol. 1, 2001, pp. 577-584.](https://web.cse.msu.edu/~cse802/notes/ConstrainedKmeans.pdf)

- `constrained_hierarchical.m` is MATLAB implementation of the hierarchical (single linkage) constrained algorithm following [[2]](https://link.springer.com/content/pdf/10.1007/11564126_11.pdf)

[[2]. Davidson I. & Ravi, S.S, Agglomerative hierarchical clustering with constraints: Theoretical and empirical results, Proceedings of the 9th European Conference on Principles and Practice of Knowledge Discovery in Databases (PKDD), Porto, Portugal, October 3-7, 2005, LNAI 3721, Springer, 59-70.](https://link.springer.com/content/pdf/10.1007/11564126_11.pdf)

- `constrained_kmeans.m` is MATLAB implementation of the two seeded consrained kmeans following 

[3]. Basu S., Banerjee A. & Mooney, R., Semi-supervised clustering by seeding, Proc. of the 19th ICML, 2002, Proc. of the 19th ICML, 2002, 19-26, doi 10.5555/645531.656012

```
@misc{KunchevaSemiSupervisedConstrainedClustering2021,
author = {Ludmila I Kuncheva},
title = {Semi-supervised-and-Constrained-Clustering},
year = {2021},
publisher = {GitHub},
journal = {GitHub repository},
howpublished = {\url{https:\\github.com\LucyKuncheva\Semi-supervised-and-Constrained-Clustering }}
}
```
