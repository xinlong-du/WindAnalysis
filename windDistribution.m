%the current method may be OK. But may need more research on directions
%with scarce data and locations with hurricanes.
clear;clc;close all;

% Connecticut
windDataCT = readtable('./Data/dataCT/station_matrix_725040.xlsx');
%%
windAnalysis(windDataCT,'CT')
%%
% Sourthen California
windDataCA = readtable('./Data/final_qc_data/station_matrix_722950.xlsx');
windAnalysis(windDataCA,'CA')

% Florida
windDataFL = readtable('./Data/final_qc_data/station_matrix_722020.xlsx');
windAnalysis(windDataFL,'FL')

function windAnalysis(windData,State)
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
dirID30=0:30:330;
dirCt30=zeros(12,1); %count of each direction
spdDir30=cell(12,1);
for i=1:length(dirID30)
    idx=find(dir==dirID30(i)|dir==dirID30(i)-10|dir==dirID30(i)+10);
    dirCt30(i)=length(idx);
    
    %wind speeds for each direction
    spdDir30{i}=[spd(idx),dir(idx)];
    pdfFit(spdDir30{i}(:,1),dirID30(i),State)
end
dirPb30=dirCt30/length(dir); %probability of each direction

hfig=figure;
bar(dirID30,dirPb30)
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

binSize=max(spd2)/10;
spd2bin=0:binSize:max(spd2);
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