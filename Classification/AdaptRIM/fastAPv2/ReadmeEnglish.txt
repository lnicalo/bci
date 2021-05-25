Help file of Fast Algorithm of Affinity Propagation Clustering under Given Number of Clusters (FastAP) (Version 2.0)

  Affinity propagation clustering (AP) is a clustering algorithm proposed in "Brendan J. Frey and Delbert Dueck. Clustering by Passing Messages Between Data Points. Science, 2007, 315(5814), 972-976". The searching process is neccesary when one demands a clustering solution under given number of clusters.
  The FastAP uses multi-grid searching to reduce the calling times of AP, and improves the upper bound of preference parameter to reduce the searching scope, so that it can (largely) enhance the speed performance of AP under given number of clusters. 

  Your tests and comments are helpful and welcome (E-mail: wangkjun@yahoo.com). The codes are available from: http://www.mathworks.com/matlabcentral/fileexchange/authors/24811
  The citation information is: K. Wang, J. Zheng. Fast Algorithm of Affinity Propagation Clustering under Given Number of Clusters. Computer Systems & Applications, 19(7):207-209, 2010. (in Chinese)

Note 1: The programs are tested under Matlab 7.2.
Note 2: The authors of the contributed files/codes hold the copyrights (see "Notice_contributedFiles.txt"):
(a) the codes of Affinity Propagation clustering are from Brendan J. Frey and Delbert Dueck.


(1) Contents of "mainFastAP_exactK.m"
  This program includes six function parts: 
Part 1: Selecting a data set & initialization. 
Part 2: Loading a data file or similarity matrix by "data_load.m"
Part 3: Running FastAP by "apclusterK_fast.m"
Part 4: Computing Fowlkes-Mallows validity index (compared with true answers) by "valid_external.m"
        Computing error rates of a clustering solution (compared with true answers) by "valid_errorate.m"


(2) Input: a data file like "yourdata.txt" 
    Data format: input data file is tab delimited text file with numeric tabular data (e.g. rows denote data points and columns are dimensions), and all the data should be numeric values and without characters and missing values. Such tab-delimited text files can be created and exported by such as Microsoft Excel.
    For example, Let there be four 4-dimensional samples (data points):
sample1:	(5.1, 3.5, 1.4, 0.2)
sample2:	(4.9, 3.0, 1.4, 0.2)
sample3:	(4.7, 3.2, 1.3, 0.2)
sample4:	(1.7, 1.2, 1.3, 0.2)
    Then, the data file looks like:
5.1	3.5	1.4	0.2
4.9	3	1.4	0.2
4.7	3.2	1.3	0.2
1.7	1.2	1.3	0.2
    When true class labels (class 1 and class 2) are available, put them in the first column of the data file:
1	5.1	3.5	1.4	0.2
1	4.9	3	1.4	0.2
2	4.7	3.2	1.3	0.2
2	1.7	1.2	1.3	0.2


(3) Output
  The class labels (clustering solutions) from AP are stored in variable "labelid" corresponding to K clusters. The rearranged labels (from 1 to K) are stored in variable "label", and the K clusters are separated in variable "C".

  
(4) Parameters
  nrun --- max iteration times of AP, default 20000 is enough for most cases.
  nconv --- convergence condition of the algorithm, default 200. The condition is more strict if bigger.  
  lam --- initial damping factor, default 0.9.
  K --- the given number of clusters.
  fastAP --- fastAP runs when 1. 


------------------------------------------------------------------------------
This software is distributed under the BSD license. 
Copyright (C) 2009.
Last modified: Nov. 3, 2009