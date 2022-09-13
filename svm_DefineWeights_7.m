%This analysis code was used in:
%Mares I, Ewing L, Papasavva E, Ducrocq E, Smith FW, Smith MLS (in press).
%Face recognition ability is manifest in early dynamic decoding of face-orientation
%selectivity – evidence from multi-variate pattern analysis of the neural
%response. Cortex.

%The code was originally created by Fraser W. Smith 
%see Smith, F.W. & Smith M.L.S. (2019). Decoding the dynamic representation of facial expressions of emotion in explicit and incidental tasks. Neuroimage, 195, 261-271.



function [weights]=svm_DefineWeights_7(model)


% a helper function to take an svm model from LIBSVM
% and define the weights for each pairwise classification pbm
% since LIBSVM is doing multiple classification by 1 VS 1 approach
% FWS 3/9/09 --- see email from Chih Jen Lin (LIBSVM)
% checked - see check svmDefineWeights.m - 7/9/09

nLabels=length(unique(model.Label));  % only for 3 classes at the moment
contrasts=nchoosek(1:nLabels, 2);
% this has the correct order - 1 Vs 2, 1 Vs 3, 2 Vs 3
nContrasts=size(contrasts,1);
weights=zeros(size(model.SVs,2),nContrasts);

clear tab;
for i=1:nContrasts
    
    
%     if(i==1) %% then contrast is 1 Vs 2
%         
%         coef=[model.sv_coef(1:model.nSV(1),1); model.sv_coef(model.nSV(1)+1:model.nSV(1)+model.nSV(2),1)];
%         SVs=[model.SVs(1:model.nSV(1),:); model.SVs(model.nSV(1)+1:model.nSV(1)+model.nSV(2),:)];
%    
%     elseif(i==2)   %% contrast is 1 Vs 3
%         
%         coef=[model.sv_coef(1:model.nSV(1),2); model.sv_coef(model.nSV(1)+model.nSV(2)+1:sum(model.nSV),1)];
%         SVs=[model.SVs(1:model.nSV(1),:); model.SVs(model.nSV(1)+model.nSV(2)+1:sum(model.nSV),:)];
% 
%     elseif(i==3)      %% contrast is 2 Vs 3
%         
%         coef=[model.sv_coef(model.nSV(1)+1:model.nSV(1)+model.nSV(2),2); model.sv_coef(model.nSV(1)+model.nSV(2)+1:sum(model.nSV),2)];
%         SVs=[model.SVs(model.nSV(1)+1:model.nSV(1)+model.nSV(2),:); model.SVs(model.nSV(1)+model.nSV(2)+1:sum(model.nSV),:)];
% 
%     end


    % first term
    pz=contrasts(i,1);
    p1=sum(model.nSV(1:pz-1))+1;
    p2=sum(model.nSV(1:pz));

    pp=contrasts(i,2)-1; % the column (1Vs2,3,4,5,6,7) - coef for 1

    % second term
    inS=sum(model.nSV(1:pp))+1;
    inE=sum(model.nSV(1:pp+1));

    tab(i,:)=[p1 p2 inS inE pp pz];

    % coef=[model.sv_coef(1:model.nSV(1),pp); model.sv_coef(model.nSV(1)+1:model.nSV(1)+model.nSV(2),1)];
    coef=[model.sv_coef(p1:p2,pp); model.sv_coef(inS:inE,pz)];
    % SVs=[model.SVs(1:model.nSV(1),:); model.SVs(model.nSV(1)+1:model.nSV(1)+model.nSV(2),:)];
    SVs=[model.SVs(p1:p2,:); model.SVs(inS:inE,:)];
 
    
    %sum(coef~=0)
    w = SVs'*coef;   %% the weights!!!;
    
    weights(:,i)=w;
    
    
end