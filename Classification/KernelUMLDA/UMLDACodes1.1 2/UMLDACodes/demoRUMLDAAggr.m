% The script demonstrates how to aggregate several R-UMLDAs to achieve good performance.
% We use 2D face data as example here, with sample output.
% Note: The results won't be identical because random initialization is involved.
% However, the deviation should be small (around 2%).
% You can customize/modify the code accordingly.
%
% %[Author Notes]%
% Author: Haiping LU
% Email : hplu@ieee.org   or   eehplu@gmail.com
% Release date: December 04, 2013 (Version 1.1)
% Please email me if you have any problem, question or suggestion
%
% %[Algorithm]%:
% This script demonstrates how to aggregate the regularized UMLDAs as 
% detailed  in the follwing paper:
%    Haiping Lu, K.N. Plataniotis, and A.N. Venetsanopoulos,
%    "Uncorrelated Multilinear Discriminant Analysis with Regularization and Aggregation for Tensor Object Recognition",
%    IEEE Transactions on Neural Networks,
%    Vol. 20, No. 1, Page: 103-123, Jan. 2009.
% Please reference this paper when reporting work done using this code.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %[Notes]%:
% A. Developed using Matlab R2006a
% B. Revision history:
%       Version 1.0 released on March 21, 2012
%       Version 1.1 released on December 04, 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc,clear all,close all;

%Load data
dataname='FERETC80A45S6/FERETC80A45S6_32x32';
load([dataname]);%load face data 
disp(['Processing ',dataname]);
numTrn=4; %number of training samples
load(['FERETC80A45S6/4Train/1']);%load training/testing partition
[nSpl,nFea] = size(fea);
fea_Train = fea(trainIdx,:);gnd_Train = gnd(trainIdx);
fea_Train = reshape(fea_Train',32,32,size(fea_Train,1));
fea = reshape(fea',32,32,nSpl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Regularization parameter used in the paper
gammas=10.^(-(200:25:699)/100);
numInit=length(gammas);
numP=35;                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Subtract the mean
TXmean=mean(fea_Train,3);%The mean
TX0=fea_Train-repmat(TXmean,[1,1, size(fea_Train,3)]);

MaxSWLmds=estMaxSWEV(TX0,gnd_Train);%estimate \lambda_{max} in the paper

disp(['Performning R-UMLDA learning']);
%%%Get multiple R-UMLDAs features
AllUs=cell(numInit,1);%Save the TVPs
allnewfeas=zeros(nSpl,numP,numInit);
for iInit=1:numInit %individual R-UMLDA, iInit is "a" in the paper
    gamma=gammas(iInit);%Regularization parameter
    %[Us] = RUMLDA(TX,gndTX,numP,gamma,MaxSWLmds,iInit)
    [Us] = RUMLDA(TX0,gnd_Train,numP,gamma,MaxSWLmds,iInit);
    AllUs{iInit}=Us;%save the TVP
    for iP=1:numP
        projFtr=ttv(tensor(fea),Us(:,iP),[1 2]);%Projection
        allnewfeas(:,iP,iInit)=projFtr.data;
    end
end
disp(['R-UMLDA learning is done']);

%%%Aggregation
%The following function corresponds to Step 2 in Fig. 4 and equations (18) to (20) in the paper
CombR1s=calcR1(allnewfeas,gnd,trainIdx,testIdx);
maxR1s=max(CombR1s);
for iInit=1:numInit
    disp(['The best recognition rate for combining ',num2str(iInit), ' learners is: ', num2str(maxR1s(iInit)*100),'%']);
end
%=================RUMLDA==========================