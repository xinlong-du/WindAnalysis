%the current method may be OK. But may need more research on directions
%with scarce data and locations with hurricanes.
clear;clc;close all;

%% Kansas
windDataSD = readtable('./Data/final_qc_data/station_matrix_726625.xlsx');
[dirPb30,spdPb30]=windAnalysis(windDataSD,'SD');

%% Kansas
windDataKS = readtable('./Data/final_qc_data/station_matrix_724585.xlsx');
[dirPb30,spdPb30]=windAnalysis(windDataKS,'KS');

%%

% Connecticut
windDataCT = readtable('./Data/dataCT/station_matrix_725040.xlsx');
[dirPb30,spdPb30]=windAnalysis(windDataCT,'CT');
%%
totalDuraCT=13836*24; %hours, 2010.12.8(5pm)-1973.1.20(5pm);
perDuraCT=height(windDataCT)/totalDuraCT;
sigDuraCT=perDuraCT*25*365*24*3600; %seconds, significant duration in 25 years
dirDuraCT=sigDuraCT*dirPb30(:,2);

for i=1:length(spdPb30)
    spdPb30{i}(:,3)=dirDuraCT(i)*spdPb30{i}(:,2);
end

fileID=fopen('./FiguresDeg30/CTspdPb30.txt','w');
for i = 1:length(spdPb30)
    for j=1:length(spdPb30{i})
        fprintf(fileID,'%7.4f %4.0f\n',spdPb30{i}(j,1),spdPb30{i}(j,3));
    end
end
fclose(fileID);
%%
% Sourthen California
windDataCA = readtable('./Data/final_qc_data/station_matrix_722950.xlsx');
windAnalysis(windDataCA,'CA')

% Florida
windDataFL = readtable('./Data/final_qc_data/station_matrix_722020.xlsx');
windAnalysis(windDataFL,'FL')

function [dirPb30,spdPb30]=windAnalysis(windData,State)
%% wind speed
spdRaw=windData.Var3;
spd=spdRaw(8:end);
spd=cellfun(@str2num,spd,'UniformOutput',false);
spd=cell2mat(spd);

%% wind directions
dirRaw=windData.Var4;
dir=dirRaw(8:end);
dir=cellfun(@str2num,dir,'UniformOutput',false);
dir=cell2mat(dir);
dir=round(dir,-1);
idx=find(dir==360);
dir(idx)=0;
idx=find(dir==350);
dir(idx)=-10;

%% calculate probabilities of different wind directions and speeds
dirID30=(0:30:330)';
dirCt30=zeros(12,1); %count of each direction
spdDir30=cell(12,1);
spdPb30=cell(12,1);
for i=1:length(dirID30)
    idx=find(dir==dirID30(i)|dir==dirID30(i)-10|dir==dirID30(i)+10);
    dirCt30(i)=length(idx);
    
    %wind speeds for each direction
    spdDir30{i}=[spd(idx),dir(idx)];
    [spdPb30{i}(:,1),spdPb30{i}(:,2)]=pdfFit(spdDir30{i}(:,1),dirID30(i),State);
end
dirPb30=[dirID30,dirCt30/length(dir)]; %probability of each direction

hfig=figure;
bar(dirPb30(:,1),dirPb30(:,2))
xlabel('Wind direction (deg)','FontSize',8,'FontName','Times New Roman')
ylabel('Probability','FontSize',8,'FontName','Times New Roman')
set(gca,'FontSize',8,'FontName','Times New Roman')
% save figure
figWidth=3.5;
figHeight=3;
set(hfig,'PaperUnits','inches');
set(hfig,'PaperPosition',[0 0 figWidth figHeight]);
fileout=strcat('.\FiguresDeg30\',State,'dir.');
print(hfig,[fileout,'tif'],'-r800','-dtiff');
end

%% lognormal: do not consider wind speeds below the threshold
function [spdBinMid,spd2prob]=pdfFit(spd,dir,State)
spd2=spd-min(spd)+1;
% method of moments
lnSpd=log(spd2);
lnTheta=mean(lnSpd);
beta=std(lnSpd);

maxSpd=91; %mph, use 50-y MRI wind speed as the maximum considered
maxSpd2=maxSpd-min(spd)+1;
binSize=maxSpd2/12;
spd2bin=(0:binSize:maxSpd2)';
spd2cdf=logncdf(spd2bin,lnTheta,beta);
spd2prob=diff(spd2cdf);
spd2binMid=spd2bin(1:end-1)+binSize/2;
spdBinMid=spd2binMid+min(spd)-1;

% plot
IM=0:0.5:60;
Pf=lognpdf(IM,lnTheta,beta);
hfig=figure;
histogram(spd,30,'Normalization','pdf')
hold on
plot(IM-1+min(spd),Pf,'k-','LineWidth',1)
xlabel('Wind speed (mph)','FontSize',8,'FontName','Times New Roman')
ylabel('PDF','FontSize',8,'FontName','Times New Roman')
set(gca,'FontSize',8,'FontName','Times New Roman')
% save figure
figWidth=3.5;
figHeight=3;
set(hfig,'PaperUnits','inches');
set(hfig,'PaperPosition',[0 0 figWidth figHeight]);
fileout=strcat('.\FiguresDeg30\',State,'pdf',num2str(dir),'.');
print(hfig,[fileout,'tif'],'-r800','-dtiff');

% plot probability
hfig=figure;
h=histogram(spd,10,'Normalization','probability');
hold on
bar(spdBinMid,spd2prob)
xlabel('Wind speed (mph)','FontSize',8,'FontName','Times New Roman')
ylabel('Probability','FontSize',8,'FontName','Times New Roman')
set(gca,'FontSize',8,'FontName','Times New Roman')
% save figure
figWidth=3.5;
figHeight=3;
set(hfig,'PaperUnits','inches');
set(hfig,'PaperPosition',[0 0 figWidth figHeight]);
fileout=strcat('.\FiguresDeg30\',State,'prob',num2str(dir),'.');
print(hfig,[fileout,'tif'],'-r800','-dtiff');
end