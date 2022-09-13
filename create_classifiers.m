%This analysis code was used in:
%Mares I, Ewing L, Papasavva E, Ducrocq E, Smith FW, Smith MLS (in press).
%Face recognition ability is manifest in early dynamic decoding of face-orientation
%selectivity – evidence from multi-variate pattern analysis of the neural
%response. Cortex.

%The code was originally created by Fraser W. Smith 
%see Smith, F.W. & Smith M.L.S. (2019). Decoding the dynamic representation of facial expressions of emotion in explicit and incidental tasks. Neuroimage, 195, 261-271.
%and was adapted to this project by Ines Mares and Fraser W. Smith.


clear all;
close all
%addpath to libsvm-3.20

rng(sum(100*clock));
nSubs=1;
timeSampMeth=2; %% if=1 uses time windows, if=2, uses each time point independently  (downsampling first might help)
participants=[]; %palce participants numbers here
codetousefirst= []; % place here code for first condition
codetousesecond= []; % place here code for second condition
%if two conditions will be used together this needs to edited here and below
gpSize=size(participants,2);
for group=1 %:ngroups
    
    resS=[]; cmsS=[]; Ws=[];
    
    for s=1:gpSize(group)  %% which group a participant belongs to
        if group==1
            subject= participants(s);
            %add groups if needed
            
        end
        for dec=1
            %selectE selects electrodes 2=use all electrodes (=1, use only the ones specified in the electrodes script)
            for selectE=1 %
                permData=0;  % if=1 do 1000 permutations for sig testing
                if(letspermute==1)
                    % fid=fopen('logFile.txt','w');
                    nPerms=100;
                else
                    nPerms=0;
                end
                
                % load data
                load(sprintf('path to data',subject));
                fprintf('!!!!!!!!Computing %d!!!!!!!!! \n', subject);
                NEEG.data=NEEG.data(:,:,NEEG.GoodCodes==codetousefirst|NEEG.GoodCodes==codetousesecond);
                NEEG.GoodCodes=NEEG.GoodCodes(NEEG.GoodCodes==codetousefirst|NEEG.GoodCodes==codetousesecond);
                codes=NEEG.GoodCodes;
                codes(NEEG.GoodCodes==codetousefirst)=1;
                codes(NEEG.GoodCodes==codetousesecond)=2;
                trialsPerCondE=histc(codes,1:2);
                minNE=min(trialsPerCondE);  %% reduce others to this size for classification purposes
                
                minN2use=minNE;
                data=NEEG.data;
                nTP=size(data,2);
                nTrials=size(data,3);
                nLb=length(unique(codes));  % number of conditions
                Lbs=unique(codes);  % what conditions
                nElectrodes=size(data,1);
                res=[]; sts=[];
                for p=1:nPerms+1  %% cycles of permutations -- for significance
                    % select the data
                    data2=[]; labels=[];
                    k=1; %l=minNE;
                    
                    for j=1:nLb %for all conditions
                        f=find(codes==Lbs(j)); %find specific condition
                        tmp=data(:,:,f); % electrodes by time by trials of specific condition
                        
                        l=k+size(tmp,3)-1;
                        for ts=1:nTP  %% decoding independent each time step
                            data2(k:l,:,ts)=squeeze(tmp(:,ts,:))'; % trials by electrode by ts
                        end
                        
                        labels(k:l,1)=j;
                        
                        k=k+(size(tmp,3)); %l=l+minNE;
                        
                    end
                    
                    % now sample the trials to be trained Vs test over 10 runs say
                    % if uneven across categories, sample the first minNE random each XV fold
                    % try a 70% to 30% trial decoding split - train /test (TSUCHIYA)
                    
                    
                    samp=[]; trainLocs=[]; testLocs=[];
                    flag=1;  %% for data normalization prior to SVM
                    nTrain=floor(minN2use*0.7);
                    nTest=minN2use-nTrain;%floor(minNE*0.3);
                    mat=zeros(size(labels,1),2);
                    
                    for i=1:20  %% 20 XV folds
                        
                        for j=1:nLb
                            f=find(labels==j);
                            samp=randperm(length(f));
                            
                            if(length(samp)>minN2use)
                                samp=samp(1:minN2use); % random choice of which ones to include
                            end
                            
                            trainLocs=f(samp(1:nTrain));
                            testLocs=f(samp(nTrain+1:end));
                            
                            mat(trainLocs,i)=1; % train
                            mat(testLocs,i)=2; % test
                            
                        end
                    end
                    
                    
                    % generate timeSampling method
                    if(timeSampMeth==1)
                        window=28;  %100
                        offset=14;  %50
                        
                        z=1; kk=1; ll=window;
                        while(ll<=nTP)
                            
                            timeSamps(z,:)=[kk ll];
                            kk=kk+offset; ll=kk+window-1;
                            z=z+1;
                            
                        end
                        %timeSamps(end,:)=[];
                        nTS=length(timeSamps); % nTimeSamples not nTimePoints!
                    else
                        % each ms
                        %data=decimate(data,4);
                        x11=size(data2,1); data3=[];
                        for ii=1:x11
                            data3(ii,:,:)=resample(double(squeeze(data2(ii,:,:)))',250,500)';
                        end
                        nTS=size(data3,3);
                        timeSamps=[1:nTS;1:nTS]';
                        %nTS=nTP;
                        
                    end
                    
                    
                    % choose some electrodes
                    % load visElecVec; %(19 most posterior but include TP7 + TP8)
                    % elecs2use=find(vec);
                    % vec codes which electrodes to use
                    
                    % filter current subs' electrodes
                    [elecs2use, nElec,eNames2use]=filterSubElecs(NEEG.chanlocs, NEEG.badchans,selectE);
                    
                    % now run a simple decoder ----
                                        
                     [a1,b1,ws]=computeClassParallel(data3,labels,mat, elecs2use, timeSamps, permData,nPerms,p,nTS,flag,Lbs,nLb);
            
                    
                    res(:,:,:,:,p)=a1;
                    sts(:,:,:,:,:,:,p)=b1;
                    
                    % fprintf(fid,'%d\n',p);
                    
                end  %% end permutation loop for accuracy estimation
                
               
                resS(:,:,:,:,:,selectE)=res;
                outname=sprintf('sub%d_group%d_Decoding_permData%d_selectE%d_timeSamp%d.mat', subject,group,permData,selectE,timeSampMeth);
                save(outname, 'resS','flag','minNE','nPerms','timeSamps','elecs2use','nTS','Ws','eNames2use','sts');
                fprintf('!!!!!!!!Computing %d!!!!!!!!! \n', subject);
                
            end %% end selectE (all or only OT electrodes)
            %
            
            
        end  % end decoding task
        
    end % subject per group
    
    % important to save eNames2Use to save the names of electrodes
    % actually used....
    % needed for mapping the weights back to electrode space.
    
end % group