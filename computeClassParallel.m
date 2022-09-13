%This analysis code was used in:
%Mares I, Ewing L, Papasavva E, Ducrocq E, Smith FW, Smith MLS (in press).
%Face recognition ability is manifest in early dynamic decoding of face-orientation
%selectivity – evidence from multi-variate pattern analysis of the neural
%response. Cortex.

%The code was originally created by Fraser W. Smith 
%see Smith, F.W. & Smith M.L.S. (2019). Decoding the dynamic representation of facial expressions of emotion in explicit and incidental tasks. Neuroimage, 195, 261-271.
%and was adapted to this project by Ines Mares and Fraser W. Smith.



function [pc,st,ws]=computeClassParallel(data2,labels,mat, elecs2use, timeSamps, permData,nPerms,p,nTS,flag,Lbs,nLb)

 pc=[]; st=[]; tLocs=[]; teLocs=[]; trLabs=[]; teLabs=[];
    train=[]; test=[]; ws=[];

    for ts=1:nTS %i=1:10  %% XV cycles -10 random splits of 70% train Vs 30% test


         %%% 900 time points X 10 XVs = 9000 * 21 binary classifiers = ~ 180,000 SVMs -- 
         % too ambitious, see Tsuchiya - overlapping time bins approach
         % e.g 100ms window with 50 ms offsets

        for i=1:20  %% as many time windows!!! 

            % get train data
            tLocs(:,i)=find(mat(:,i)==1);
            train=data2(tLocs(:,i),elecs2use,timeSamps(ts,1):timeSamps(ts,2));
            trLabs(:,i)=labels(tLocs(:,i));

            % get test data
            teLocs(:,i)=find(mat(:,i)==2);
            test=data2(teLocs(:,i),elecs2use,timeSamps(ts,1):timeSamps(ts,2));
            teLabs(:,i)=labels(teLocs(:,i));
            
            if(permData==1 && p<=nPerms)
                tmpZ=randperm(length(trLabs(:,1)));
                trLabs(:,i)=trLabs(tmpZ,i);
            end

            % stack train and test matrices across timeSamples
            [train,test]=stackMats(train,test);

            % normalize data
            [train,test]=svm_scale_data_mvpaC(train, test, flag);

            % runClassifiers
            [gnb_class(:,i,ts),err,post,logp,coef]=classify(test,train,trLabs(:,i),'diagLinear');

            % train SVM 
            svm_model=[];
            %  svm_model=svmtrain(trLabels, train, opts);
            svm_model=svmtrain(trLabs(:,i), train,'-t 0 -c 1');    % -t 0 = linear SVM, -c 1 = cost value of 1
            ws{i,ts}=svm_DefineWeights_7(svm_model);

            % test SVM
            [svm_class(:,i,ts),accuracy,dec]=svmpredict(teLabs(:,i),test,svm_model);

            % test SVM on average patterns in independent test data
            for ii=1:nLb
                avL=find(teLabs(:,i)==ii);
                avT(ii,:)=mean(test(avL,:));  %% mean across test trials per condition
            end
            [svm_classAv(:,i,ts),acc2,dec2]=svmpredict(Lbs',avT,svm_model);

        %     %---------------% compute performance
             pc(i,ts,1)=length(find(gnb_class(:,i,ts)==teLabs(:,i))) / length(teLabs(:,i));
             pc(i,ts,2)=length(find(svm_class(:,i,ts)==teLabs(:,i))) / length(teLabs(:,i));
             pc(i,ts,3)=length(find(svm_classAv(:,i,ts)==Lbs')) / length(Lbs);
             
             % more elaborate
             a1=deriveCM_pvals(svm_class(:,i,ts),teLabs(:,i),nLb);
             a2=deriveCM_pvals(svm_classAv(:,i,ts),Lbs',nLb);

             st(:,:,i,ts,1)=a1.cmS;
             st(:,:,i,ts,2)=a2.cmS;
        end
            
    end
    
   % fprintf(fid,'%d\n',p);