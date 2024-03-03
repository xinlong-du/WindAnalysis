clear;clc;close all;

%% Texas
windDataCT = readtable('./Data/final_qc_data/station_matrix_722650.xlsx');
[dirPb30,spdPb30]=windAnalysis(windDataCT,'TX');

spdRaw=windDataCT.Var3;
spd=spdRaw(8:end);
spd=cellfun(@str2num,spd,'UniformOutput',false);
spd=cell2mat(spd);

timeRaw=windDataCT.StationDescription_MIDLANDREGIONALAIRTERMINAL;
timeDate=timeRaw(8:end);
time=datetime(timeDate,'InputFormat','M/d/yyyy h:mm:ss a');

hfig=figure;
plot(time,spd,'k.','MarkerSize',5)
xlabel('Date','FontSize',8,'FontName','Times New Roman')
ylabel('Wind speed (mph)','FontSize',8,'FontName','Times New Roman')
set(gca,'FontSize',8,'FontName','Times New Roman')
% save figure
figWidth=4;
figHeight=2.8;
set(hfig,'PaperUnits','inches');
set(hfig,'PaperPosition',[0 0 figWidth figHeight]);
figname=('.\FiguresDeg30TX\0windSpeeds.');
print(hfig,[figname,'tif'],'-r300','-dtiff');

%%
totalDuraCT=13836*24; %hours, 2010.12.8(5pm)-1973.1.20(5pm);
perDuraCT=height(windDataCT)/totalDuraCT;
sigDuraCT=perDuraCT*25*365*24*3600; %seconds, significant duration in 25 years
dirDuraCT=sigDuraCT*dirPb30(:,2);

for i=1:length(spdPb30)
    spdPb30{i}(:,3)=dirDuraCT(i)*spdPb30{i}(:,2);
end

fileID=fopen('./FiguresDeg30TX/CTspdPb30.txt','w');
for i = 1:length(spdPb30)
    for j=1:length(spdPb30{i})
        fprintf(fileID,'%7.4f %4.0f\n',spdPb30{i}(j,1),spdPb30{i}(j,3));
    end
end
fclose(fileID);

function [dirPb30,spdPb30]=windAnalysis(windData,State)
%% wind speed
spdRaw=windData.Var3;
spd=spdRaw(8:end);
spd=cellfun(@str2num,spd,'UniformOutput',false);
spd=cell2mat(spd);

hfig=figure;
h=histogram(spd,30);
xlabel('Wind speed (mph)','FontSize',8,'FontName','Times New Roman')
ylabel('Hours','FontSize',8,'FontName','Times New Roman')
set(gca,'FontSize',8,'FontName','Times New Roman')
set(gca,'YScale','log')
ylim([0.1 10000])

% save figure
figWidth=3.5;
figHeight=3;
set(hfig,'PaperUnits','inches');
set(hfig,'PaperPosition',[0 0 figWidth figHeight]);
fileout=strcat('.\FiguresDeg30TX\',State,'aSpd.');
print(hfig,[fileout,'tif'],'-r300','-dtiff');

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
fileout=strcat('.\FiguresDeg30TX\',State,'dir.');
print(hfig,[fileout,'tif'],'-r300','-dtiff');
end

%% lognormal: do not consider wind speeds below the threshold
function [spdBinMid,spd2prob]=pdfFit(spd,dir,State)
spd2=spd-min(spd)+1;
% method of moments
lnSpd=log(spd2);
lnTheta=mean(lnSpd);
beta=std(lnSpd);

maxSpd2=logninv(0.999,lnTheta,beta);
binSize=maxSpd2/10;
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
fileout=strcat('.\FiguresDeg30TX\',State,'pdf',num2str(dir),'.');
print(hfig,[fileout,'tif'],'-r300','-dtiff');

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
fileout=strcat('.\FiguresDeg30TX\',State,'prob',num2str(dir),'.');
print(hfig,[fileout,'tif'],'-r300','-dtiff');
end