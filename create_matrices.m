%This analysis code was used in:
%Mares I, Ewing L, Papasavva E, Ducrocq E, Smith FW, Smith MLS (in press).
%Face recognition ability is manifest in early dynamic decoding of face-orientation
%selectivity – evidence from multi-variate pattern analysis of the neural
%response. Cortex.

%This code was originally created by Ines Mares



clear all
close all
group1=[]; %this code works to produce continous data but also to create graphics split in two groups
group2=[];
pathclassifiers='';% path to load classifier files
filerand=''; %file name for rand files without the 'sub' or subject number 
fileclassifier=''; %file name for classifier files  without the 'sub' or subject number 
gpSize=[size(group1,2) size(group2,2)];
randcond=zeros(gpSize(1),2,175,1000);
actualcond=zeros(gpSize(1),2,175,100);
permuteddistribution=zeros(gpSize(1),2,175,1000);
for group=1:2 %:ngroups
    for s=1:gpSize(group)  %% which group a participant belongs to
        if group==1
            subject= group1(s);
        elseif group==2
            subject= group2(s);   
        end
            load(strcat(pathclassifiers,sprintf('sub%d', subject),filerand));
            randcond(s,group,:,:)= squeeze(mean(resS(:,:,3,:,:),1));
            
            load(strcat(pathclassifiers,sprintf('sub%d', subject),fileclassifier));
            actualcond(s,group,:,:)= squeeze(mean(resS(:,:,3,:,1:100),1));
        
        
        permuteddistribution(s,group,:,:)=randcond(s,group,:,:);
        permuteddistribution(s,group,:,1)=actualcond(s,group,:,1);
    end
end

outname='permutteddistribution.mat';
save(outname, 'permuteddistribution');
outname='randomdistribution.mat';
save(outname, 'randcond');
outname='actualdistribution.mat';
save(outname, 'actualcond');

