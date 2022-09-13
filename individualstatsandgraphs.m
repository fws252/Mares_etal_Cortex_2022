%This analysis code was used in:
%Mares I, Ewing L, Papasavva E, Ducrocq E, Smith FW, Smith MLS (in press).
%Face recognition ability is manifest in early dynamic decoding of face-orientation
%selectivity – evidence from multi-variate pattern analysis of the neural
%response. Cortex.

%This code was originally created by Ines Mares


clear all
close all

%load file with permutations for chance level distribution (1000
%permutations)
filepermuted=''; %path and file name for matrice with classifiers generated from random labels for individual analysis chance level
load('filepermuted')

%details for classification
pathclassifiers='';% path to load classifier files
fileclassifier=''; %file name for classifier files  without the 'sub' or subject number


%get groups - place participants here (this was created to deal with
%unbalanced group sizes)
group1=[];
group2=[];
gpSize=[size(group1,2) size(group2,2)];

alphalevel = .05; % alpha
intervaltoconsider=65:175;
baseline=1:50;
centile=zeros(max(gpSize),size(gpSize,2),size(permuteddistribution,3));
sigconsiwocor=zeros(1,175);
sigcon=zeros(1,175);
timeconsiderpeak=[]; %edit here for timewindow in which to search for peak decoding
            

endpoint=zeros(max(gpSize),size(gpSize,2),1);
startpoint=zeros(max(gpSize),size(gpSize,2),1);
maxdecodingsecond=zeros(max(gpSize),size(gpSize,2),1);
latmaxdecodingsecond=zeros(max(gpSize),size(gpSize,2),1);
maxdecodingfirst=zeros(max(gpSize),size(gpSize,2),1);
latmaxdecodingfirst=zeros(max(gpSize),size(gpSize,2),1);
maxdecodingall=zeros(max(gpSize),size(gpSize,2),1);
latmaxdecodingall=zeros(max(gpSize),size(gpSize,2),1);
part=1; %counter for individual graph titles


for group=1:2 %:ngroups
    
    for s=1:gpSize(group)  %% which group a participant belongs to
        if group==1
            subject= group1(s);
        elseif group==2
            subject= group2(s);
        end
        
        %load individual participant classifier data
        load(strcat(pathclassifiers,sprintf('sub%d', subject),fileclassifier));
        actualcond= squeeze(mean(mean(resS(:,:,3,:,1:100),1),5)); %average across crossvalidations
        
        % for each timebin check the centile of the actual condition
        % compared to the distribution generated with random labels (and
        % one correct classification)
        
        for timeb=1:size(permuteddistribution,3)
            
            timetoanalise=actualcond(1,timeb);
            belowactual = sum(permuteddistribution(s,group,timeb,:) < timetoanalise);
            centile(s,group,timeb) =  1-((belowactual)/length(permuteddistribution(s,group,timeb,:)));
            
        end
        %compare with alpha level
        sigwocorr=squeeze(centile(s,group,intervaltoconsider)<alphalevel);
        
        %significance without correction of the time window analysed
        sigconsiwocor(intervaltoconsider)=sigwocorr';
        sigwocorr=sigconsiwocor;
        
        %fdr correction of the timeline analysed
        b=[];
        a=[];
        [a,b]=fdr(squeeze(centile(s,group,intervaltoconsider)),alphalevel);
        sigcon(intervaltoconsider)=b;
        
        %generate graphs
        
        mcond=squeeze(mean(resS(:,:,3,1,:),1));
        mrand=squeeze(permuteddistribution(s,group,:,:));
        m2rand=[];
        m2=[];
        x = [];
        minus = [];
        plus = [];
        patchedzone = [];
        meanline=[];
        
        figure;
        stdpatch=squeeze(std(mcond,1,2));
        errorpatch=stdpatch;
        m2=squeeze(mean(mcond,2));
        x = (1:size(m2,1))';
        minus= (m2 - errorpatch);
        plus = (m2 + errorpatch);
        patchedzone = patch([x; x(end:-1:1); x(1)], [minus; plus(end:-1:1); minus(1)], 'r');
        meanline(1) = line(x,m2);
        set(patchedzone, 'facecolor', [1 0.8 0.8], 'edgecolor', 'none');
        alpha(0.8)
        set(meanline(1), 'color', 'r');
        line(x,ones(size(x,2)) * 0.5,'Color','black','LineStyle','--')
        hold on
        
        stdpatchrand=squeeze(std(mrand,1,2));
        errorpatchrand=stdpatchrand;
        m2rand=squeeze(mean(mrand,2));
        x = (1:size(m2rand,1))';
        minus = (m2rand - errorpatchrand);
        plus = (m2rand + errorpatchrand);
        patchedzone = patch([x; x(end:-1:1); x(1)], [minus; plus(end:-1:1); minus(1)], 'g');
        meanline(2) = line(x,m2rand);
        set(patchedzone, 'facecolor', [0.8 1  0.8], 'edgecolor', 'none');
        alpha(0.8)
        set(meanline(2), 'color', 'g');
        line(x,ones(size(x)) * 0.5,'Color','black','LineStyle','--')
        title(part);
        part=part+1;
        
        ax = gca;
        ax.XTick=[0 50 175];
        ax.XTickLabel = { '-200','0','500'};
        ax.YLim = [0 1];
        
        %plot fdr correctd significance line
        actuallysigfdr = (sigcon(:)==1);
        actuallynonsigfdr = (sigcon(:)==0);
        signlinefdr=1:size(m2rand,1);
        signlinefdr(actuallynonsigfdr)=NaN;
        signlinefdr(actuallysigfdr )=0.1;
        
        plot(x,signlinefdr,'.r','MarkerSize',10,'LineWidth',3);
        
        %get individual stats
        %get peakdecoding and latency
        [PKSMVPAall,LOCSMVPAall]= findpeaks(m2(timeconsider),'SortStr','descend');
        if isempty(PKSMVPAall)==0
            maxdecodingall(s,group,:)=PKSMVPAall(1);
            latmaxdecodingall(s,group,:)=LOCSMVPAall(1)+timeconsider(1)-1;
        else
            maxdecodingall(s,group,:)=0;
            latmaxdecodingall(s,group,:)=0;
        end
        
        
        % get sustainability (percentage of significant decoding)
        
        persigperpart(s,group,:)=sum(sigcon(1,:)==1)/size(intervaltoconsider,2)*100;
        
       % get onset of significance above baseline
        
       for timeb=1:size(permuteddistribution,3)
            if sigcon(1,timeb)==1 && (m2(timeb)>max(m2(baseline)))
                fdractsigstartbiggerthanbaseline(s,group,:)=timeb;         
                break
            end
       end
    end
end

