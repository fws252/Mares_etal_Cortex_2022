%This analysis code was used in:
%Mares I, Ewing L, Papasavva E, Ducrocq E, Smith FW, Smith MLS (in press).
%Face recognition ability is manifest in early dynamic decoding of face-orientation
%selectivity – evidence from multi-variate pattern analysis of the neural response.Cortex.

%The code was originally created by Fraser W. Smith 
%see Smith, F.W. & Smith M.L.S. (2019). Decoding the dynamic representation of facial expressions of emotion in explicit and incidental tasks. Neuroimage, 195, 261-271.
%and was adapted to this project by Ines Mares and Fraser W. Smith.



function [elecs2use, nElec,names]=filterSubElecs(chanlocs, bcindx,selectE)

% function to work out what electrodes to include in a given analysis
% what we want
% make not not to include EOG channels and also T7/T8 (mastoids) which are
% general reference channels - also FZ - central reference
% selectE=1, use occ/par electrodes, =2, use all electrodes (nice for
% weight maps?)

if(selectE==1)
    % occ/parietal electrodes
     desiredE=cell(1,9);
     desiredE={'O1','O2','P7','P8','P3','P4','Pz','TP9','TP10'};
%       desiredE=cell(1,11);
%       desiredE={'Fp1','Fp2','F7','F8','F3','F4','Fz','FC5','FC6','FC1','FC2'};
elseif(selectE==2)
    % all valid electrodes
    l1=length(chanlocs);
    for i=1:l1
       listE{i}=chanlocs(i).labels; 
    end
    % remove ref channels and EOG
    
    chans2remove={'EOGV','EOGHL','EOGHR','EOGVa','Fz'};
    for j=1:length(chans2remove)
       xx=strcmp(listE,chans2remove{j});
       if(sum(xx)~=0)
           listE(find(xx))=[]; % remove the channel
           fprintf('removed EOG');
       end
    end
 
    desiredE=listE;
end

% what is there
x1=struct2cell(chanlocs);
eNames=x1(1,:);


% find locations
nDesElec=length(desiredE);

eLocs=[];
for i=1:nDesElec
   
    tmp=find(strcmp(eNames,desiredE{i}));
    if(~isempty(tmp))
        eLocs(i)=tmp;
    end
end

% to be sure
f=find(eLocs);
names=eNames(eLocs(f));

% remove any bad channels
z=1; 
for i=1:length(f)
    for j=1:length(bcindx)
        if(eLocs(f(i))==bcindx(j))
            esOut(z)=i; z=z+1;
            %eLocs(f(i))=[]; % remove any bad channel remaining
        end
    end
end
if(exist('esOut','var'))
    if(sum(esOut)==0)
        % do nothing
        else
        eLocs(esOut)=[];
        names(esOut)=[];
    end
end
    f=find(eLocs);

    % output
    elecs2use=eLocs(f);
    nElec=length(f);