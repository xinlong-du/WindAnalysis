%the current method may be OK. But may need more research on directions
%with scarce data and locations with hurricanes.
clear;clc;close all;

% Connecticut
windDataCT = readtable('./Data/dataCT/station_matrix_725040.xlsx');

spdRaw=windDataCT.Var3;
spd=spdRaw(8:end);
spd=cellfun(@str2num,spd,'UniformOutput',false);
spd=cell2mat(spd);

timeRaw=windDataCT.StationDescription_BRIDGEPORTSIKORSKYMEMORIALA;
timeDate=timeRaw(8:end);
time=datetime(timeDate,'InputFormat','M/d/yyyy h:mm:ss a');
%%
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
figname=('.\Figures\0windSpeeds.');
print(hfig,[figname,'tif'],'-r500','-dtiff');
%%
windAnalysis(windDataCT,'CT')

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

hfig=figure;
histogram(dir,36,'Normalization','pdf')
xlabel('Wind direction (deg)','FontSize',8,'FontName','Times New Roman')
ylabel('PDF','FontSize',8,'FontName','Times New Roman')
xlim([0 350])
xticks(0:50:350)
set(gca,'FontSize',8,'FontName','Times New Roman')
% save figure
figWidth=3.5;
figHeight=3;
set(hfig,'PaperUnits','inches');
set(hfig,'PaperPosition',[0 0 figWidth figHeight]);
fileout=strcat('.\Figures\',State,'dir.');
print(hfig,[fileout,'tif'],'-r800','-dtiff');
%% seperate wind speeds with different directions
spdDir=cell(36,1);
dirID=unique(dir);
for i=1:length(dirID)
    idx=find(dir==dirID(i));
    spdDir{i}=[spd(idx),dir(idx)]; %data are not enough for some directions
end

%% fit distribution for wind speeds in each 10 deg
for i=1:length(dirID)
    pdfFit(spdDir{i}(:,1),spdDir{i}(1,2),State)
end
end

%% lognormal: do not consider wind speeds below the threshold
function pdfFit(spd,dir,State)
spd2=spd-min(spd)+1;
% method of moments
lnSpd=log(spd2);
lnTheta=mean(lnSpd);
beta=std(lnSpd);
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
fileout=strcat('.\Figures\',State,num2str(dir),'.');
print(hfig,[fileout,'tif'],'-r800','-dtiff');
end