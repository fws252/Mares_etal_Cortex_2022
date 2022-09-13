%%
%Accuracy plots
clear
load('all_timesample.mat')
m=squeeze(mean(resSall,1));

gpSize=[22,24,21,27];

for group=1:4
m2=squeeze(mean(m(:,:,:,group,1:gpSize(group)),5));
s=squeeze(std(m(:,:,:,group,1:gpSize(group)),1,5));   
figure, errorbar(m2(:,1:3,2),s(:,1:3,2)./sqrt(gpSize(group)))
ax = gca;
ax.XTickLabel = { '-200','-120','-40','40','120', '200','280', '360', '440', '520'};
title(group);
name=sprintf('C:\\Users\\Ines\\Desktop\\post doc\\expression EEG\\Images\\MVPA\\MVPA average\\Accuracy_timesample_%d', group);
%print (name, '-dtiff', '-r300')

end