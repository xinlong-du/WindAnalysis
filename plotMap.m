close all; clear; clc;

%% load weather stations
stations = readtable('./Data/stations_analyzed.csv');

%% plot usa map
hfig=figure;
states = shaperead('usastatehi',...
   'UseGeoCoords',true);
ax=usamap("conus");
geoshow(states,'FaceColor','none')
setm(gca,'FontSize',8,'FontName','Times New Roman')
% gridm('on');
% gridm('mlinelocation',0.2,'MLabelLocation',1,'plinelocation',0.2,'PLabelLocation',1,'GColor','k','GLineWidth',0.5,'GLineStyle',':')
framem off
gridm off
mlabel off
plabel off
hold on

%% plot weather stations
lat=stations.LAT;
lon=stations.LON;
for i=1:height(stations)
    latI=str2num(lat{i})/1000.0;
    lonI=str2num(lon{i})/1000.0;
    if ~isempty(latI)
        plotm(latI,lonI,'r.','MarkerSize',5)
    end
end

% save figure
figWidth=7.5;
figHeight=4.65;
set(hfig,'PaperUnits','inches');
set(hfig,'PaperPosition',[0 0 figWidth figHeight]);
figname=('.\Figures\0stations.');
print(hfig,[figname,'tif'],'-r300','-dtiff');