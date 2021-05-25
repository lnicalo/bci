function CombR1s=calcR1(allnewfeas,gnd,trainIdx,testIdx)
%calcR1(allnewfeas,gnd,trainIdx,testIdx);
%
%This code is for matching face images. 
%For matching gait sequences, the code can be modified with reference to my latest MPCA code
%release version 1.3: http://mathworks.com/matlabcentral/fileexchange/26168
%
%Haiping Lu (hplu@ieee.org) - December 04, 2013

[nSmp,numP,numU]=size(allnewfeas);
maxDim=numP;
testDims=1:maxDim;
nDim=max(size(testDims));

nTrain = length(trainIdx);
nTest = length(testIdx);
gnd_Train = gnd(trainIdx);
gnd_Test = gnd(testIdx);
classLabel = unique(gnd_Train);
nClass = length(classLabel);%Number of classes
ClsIdxs=cell(nClass,1);Ns=zeros(nClass,1);
for i=1:nClass
    ClsIdxs{i}=find(gnd_Train==classLabel(i));
    Ns(i)=length(ClsIdxs{i});
end

R1s=zeros(nDim,numU);%Results by individual learner. You can examine this if interested.
CombR1s=zeros(nDim,numU);
for iDim=1:nDim%Study different feature dimensions
    Dim=testDims(iDim);
    clsDists=zeros(nTest,nClass,numU);
    for iU=1:numU%Distance calculation for individual learners
        feaTrn=allnewfeas(trainIdx,1:Dim,iU);
        feaTst=allnewfeas(testIdx,1:Dim,iU);
        DMat=EuDistCal(feaTst,feaTrn);
        [minDs,minIdxs]=min(DMat, [], 2);
        IDs=gnd_Train(minIdxs);
        R1s(iDim,iU)=sum(IDs==gnd_Test)/nTest;
        for iCls=1:nClass
            clsDMat=DMat(:,ClsIdxs{iCls});
            clsDists(:,iCls,iU)=min(clsDMat,[],2);
        end
        %Scaling to [0,1]
        mindist=min(clsDists(:,:,iU),[],2);
        maxdist=max(clsDists(:,:,iU),[],2);
        clsDists(:,:,iU)=(clsDists(:,:,iU)-repmat(mindist,1,nClass))./(repmat(maxdist-mindist,1,nClass));
        clear DMat clsDMat maxdist mindist IDs minDs minIdxs
    end
    for iComb=1:numU%Aggregation
        combDist=sum(clsDists(:,:,1:iComb),3);
        [minDs,minIdxs]=min(combDist,[],2);
        IDs=classLabel(minIdxs);
        CombR1s(iDim,iComb)=sum(IDs==gnd_Test)/nTest;
    end
end

%Euclidean/L2 distance calculation between (training & testing) features
function D = EuDistCal(fea_a,fea_b) 
[nSmp_a, nFea] = size(fea_a);
[nSmp_b, nFea] = size(fea_b);
aa = sum(fea_a.*fea_a,2);
bb = sum(fea_b.*fea_b,2);
ab = fea_a*fea_b';clear fea_a fea_b
D = sqrt(repmat(aa, 1, nSmp_b) + repmat(bb', nSmp_a, 1) - 2*ab);