close all;clear;clc;
%% load weather stations
stations = readtable('./Data/stations_analyzed.csv');

%%
states=stations.STATE;
%idx=strfind(states,'CA');
idx=find(ismember(states,'CA'));
stationsCA=stations.USAF(idx);

%% load weather stations
listing=dir('./Data/final_qc_data');
listing=listing(3:end-1);
idxCA=[];
listingNames=[];
for i=1:length(listing)
    stationName=listing(i).name;
    stationName2=stationName(16:21);
    listingNames=[listingNames;str2double(stationName2)];
    idx=find(ismember(stationsCA,stationName2));
    if ~isempty(idx)
        idxCA=[idxCA;i];
    end
end
maxSpdDir1=load('maxSpdDir1.mat');
maxSpdDir2=load('maxSpdDir2.mat');
maxSpdDir=[maxSpdDir1.maxSpdDir(1:959,:);maxSpdDir2.maxSpdDir(960:end,:)];
maxSpdDir=[maxSpdDir,listingNames,(1:length(listing))'];

%%
maxSpdDirCA=maxSpdDir(idxCA,:);
sortCASpd=sortrows(maxSpdDirCA,1,'descend');
sortCABytes=sortrows(maxSpdDirCA,3,'descend');