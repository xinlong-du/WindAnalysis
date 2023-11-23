close all; clear; clc;

%% load weather stations
listing=dir('./Data/final_qc_data');
listing=listing(3:end-1);
maxSpdDir=zeros(length(listing),3);
for i=1:length(listing)
    station=listing(i).name;
    windData=readtable(strcat('./Data/final_qc_data/',station));
    [maxSpdDir(i,1),maxSpdDir(i,2)]=windAnalysis(windData);
    maxSpdDir(i,3)=listing(i).bytes;
end

save("maxSpdDir.mat","maxSpdDir")

function [maxSpd,mDir]=windAnalysis(windData)
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

%% remove dir=80, 90, 100, 260, 270, 280, and find max speed for other directions
idx=find(dir==80 | dir==90 | dir==100 | dir==260 | dir==270 | dir==280);
spd(idx)=[];
dir(idx)=[];
[maxSpd,idx]=max(spd);
mDir=dir(idx);
end