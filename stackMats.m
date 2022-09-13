%This analysis code was used in:
%Mares I, Ewing L, Papasavva E, Ducrocq E, Smith FW, Smith MLS (in press).
%Face recognition ability is manifest in early dynamic decoding of face-orientation
%selectivity – evidence from multi-variate pattern analysis of the neural
%response. Cortex.

%The code was originally created by Fraser W. Smith 
%see Smith, F.W. & Smith M.L.S. (2019). Decoding the dynamic representation of facial expressions of emotion in explicit and incidental tasks. Neuroimage, 195, 261-271.



function [newT,newTe]=stackMats(train,test)

[nTrials,nElectrodes,nTS]=size(train);
k=1; l=nElectrodes;

for i=1:nTS
    newT(:,k:l)=train(:,:,i);
    newTe(:,k:l)=test(:,:,i);
    k=k+nElectrodes; l=l+nElectrodes;
end

