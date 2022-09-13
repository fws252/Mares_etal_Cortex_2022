%This analysis code was used in:
%Mares I, Ewing L, Papasavva E, Ducrocq E, Smith FW, Smith MLS (in press).
%Face recognition ability is manifest in early dynamic decoding of face-orientation
%selectivity – evidence from multi-variate pattern analysis of the neural
%response. Cortex.

%This code was originally created by Ines Mares

clear all
close all

%load data
filerand=''; %path and file name for matrice with classifiers generated from random labels
fileclassifier=''; %path and file name for matrice with classifiers generated from actual labels

load('filerand')
load('fileclassifier')
%
intervaltoconsider=65:175; %timepoints to consider

%get groups - place participants here (this was created to deal with
%unbalanced group sizes)
group1=[];
group2=[];

gpSize=[size(group1,2) size(group2,2)];

%colours to use
%colour for lines
colours={'r';'b'};
colourssig={'.r';'.b'};

%colours for patch (error)
colourpatch=[0.98824  0.75294  0.54902 ; 0.56863  0.74902  0.85882];
colourpatchrand=[0.98824  0.55294  0.34902; 0.36863  0.54902  0.85882];

%position of significance line
pos=[0.35 0.34];

%average 100 permutations for robustness
actualcond=squeeze(mean(actualcond(:,:,:,1:100),4));
randcond=squeeze(mean(randcond(:,:,:,1:100),4));

%get stats with paired t tests and correct for multiple comparisons (fdr
%correction)
figure;
hold on
for group=1:2
    mcond=squeeze(actualcond(1:gpSize(group),group,:));
    mrand=squeeze(randcond(1:gpSize(group),group,:));
    m2=[];
    x = [];
    minus = [];
    plus = [];
    patchedzone = [];
      
    %get stats
    for timeb=1:size(mcond,2)
        [h,p,ci,stats] = ttest(mcond(:,timeb),mrand(:,timeb));
        groupp(timeb,group)=p;
        groupt(timeb,group)=stats.tstat;
        groupp2=groupp./2; % for one tailed statistics
    end
    %correct for fdr
    b=[];
    [a,b]=fdr(groupp2(intervaltoconsider,group),.05);
    btemp(intervaltoconsider)=b;
    b=btemp;
    
    %create graph
    stdpatch=squeeze(std(mcond,1,1));
    errorpatch=stdpatch./sqrt(gpSize(group));
    m2=squeeze(mean(mcond,1));
    x = (1:size(m2,2))';
    minus = (m2 - errorpatch)';
    plus = (m2 + errorpatch)';
    patchedzone = patch([x; x(end:-1:1); x(1)], [minus; plus(end:-1:1); minus(1)], colours{group,1});
    meanline(group) = line(x,m2);
    set(patchedzone, 'facecolor', colourpatch(group,:), 'edgecolor', 'none');
    alpha(0.5)
    set(meanline(group), 'color', colours{group,1});
    line(x,ones(size(x)) * 0.5,'Color','black','LineStyle','--')
    
    stdrandpatch=squeeze(std(mrand,1,1));
    errorrandpatch=stdrandpatch./sqrt(gpSize(group));
    m2=squeeze(mean(mrand,1));
    x = (1:size(m2,2))';
    minus = (m2 - errorrandpatch)';
    plus = (m2 + errorrandpatch)';
    patchedzone = patch([x; x(end:-1:1); x(1)], [minus; plus(end:-1:1); minus(1)], colours{group,1});
    meanline(group+2) = line(x,m2,'LineStyle','--');
    set(patchedzone, 'facecolor', colourpatchrand(group,:), 'edgecolor', 'none');
    alpha(0.5)
    set(meanline(group+2), 'color', colours{group,1});
    line(x,ones(size(x)) * 0.5,'Color','black','LineStyle','--')
    ylim([0.2 1])        
   
    %change axis to correct time
    ax = gca;
    ax.XTick = [1 25 50 75 100 125 150 175];
    ax.XTickLabel = { '-200','-100','0','100','200','300','400', '500'};    
    
    %place significance on plot (one tailed)
    
    actuallysigfdr = (b(:)==1)& groupt(:,group)>0;
    actuallynonsigfdr = (b(:)==0)|((b(:)==1)&groupt(:,group)<0);
    
    signlinefdr=1:size(m2,1);
    signlinefdr(actuallynonsigfdr)=NaN;
    signlinefdr(actuallysigfdr)=pos(1,group);
    
    plot(x,signlinefdr,colourssig{group,1},'MarkerSize',10,'LineWidth',3);
     
    end

 l{1}='Low CFMT';
 l{2}='High CFMT';
 l{3}='Low CFMT chance level';
 l{4}='High CFMT chance level';
 legend(meanline, l);
 legend boxoff
 hold off
