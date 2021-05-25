%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Matlab source codes for                                                %
%          Uncorrelated Multilinear Discriminant Analysis (UMLDA)             %
%                                                                                                             %
% Author: Haiping LU                                                                              %
% Email : hplu@ieee.org   or   eehplu@gmail.com                                  %
% Release date: December 04, 2013                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[Algorithm]%

The matlab codes provided here implement the UMLDA algorithm (as well as its 
regularized and aggregated versions) presented in the paper "UMLDA_TNN09.pdf" 
included in this package:

        Haiping Lu, K.N. Plataniotis, and A.N. Venetsanopoulos,
        "Uncorrelated Multilinear Discriminant Analysis with Regularization and Aggregation for
        Tensor Object Recognition",
        IEEE Transactions on Neural Networks,
        Vol. 20, No. 1, Page: 103-123, Jan. 2009.

[Files]
RUMLDA.m:           the Regularized UMLDA (R-UMLDA)
demoRUMLDAAggr.m: sample code for R-UMLDA aggregation with sample output 
estMaxSWEV.m:       estimate \lambda_{max} in the paper, used for regularization 
---------------------------


%[Data]%

All data used in the paper are included in this package:

Directory "PIEP3I3" contains the PIE face data and their partitions used in the paper.
Directory "FERETC80A45S6" contains the FERET face data for C=80 and their partitions.
Directory "FERETC160A45S6" contains the FERET face data for C=160 and their partitions.
Directory "FERETC240A45S6" contains the FERET face data for C=240 and their partitions.
Directory "FERETC320A45S6" contains the FERET face data for C=320 and their partitions.
Directory "USFGait17_32x22x10" contains the gait data used in the paper.
---------------------------


%[Usages]%

Please refer to "demoRUMLDAAggr.m" for example usage on 2D data
"FERETC80A45S6_32x32" in the directory "FERETC80A45S6", which is used in the 
paper above. The partition used in the paper is included in the directory 
"FERETC80A45S6\4Train" for L=4.
---------------------------

%[Sample face recognition results for reference]%

calcR1.m: calculate the classification rates for aggregated learners

Run demoRUMLDAAggr.m to get sample face recognition results 

FRSampleOutput.txt contains sample output* in the command window.
*Note: The results won't be identical because random initialization is involved.
However, the deviation should be small (around 2%).
---------------------------


%[Toolbox needed]%:

This code needs the tensor toolbox available at 
http://csmr.ca.sandia.gov/~tgkolda/TensorToolbox/
This package includes tensor toolbox version 2.1 for convenience.
---------------------------


%[Restriction]%

In all documents and papers reporting research work that uses the matlab codes 
provided here, the respective author(s) must reference the following paper: 

[1]    Haiping Lu, K.N. Plataniotis, and A.N. Venetsanopoulos, 
        "Uncorrelated Multilinear Discriminant Analysis with Regularization and Aggregation for            
        Tensor Object Recognition",
        IEEE Transactions on Neural Networks,
        Vol. 20, No. 1, Page: 103-123, Jan. 2009.
---------------------------


%[Additional Resources]%

The BibTeX file "UMLDApublications" contains the BibTex for UMLDA and 
related works. The included survey paper "SurveyMSL_PR2011.pdf" discusses the 
relations between UMLDA and related works.
---------------------------


%[Comment/Question?]%

Please send your comment (e.g., ways to improve the codes) or question (e.g., 
difficulty in using the codes) to hplu@ieee.org or eehplu@gmail.com
---------------------------


%[Update history]%

1. March 21, 2012: Version 1.0 is released.

2. December 04, 2013: Version 1.1 is released.
[calcR1.m is provided to demonstrate classification with aggregation]
[Sample output on 2D face data is included for reference]