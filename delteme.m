
clc
clear all

% TecDEM execution scripts
scpAddpathlist();

folder = 'data/Pakistan/'; % Folder location to read in the big mosaic file or input data
file = 'Potwar.tif'; % File name in the above mentioned folder

outfolder = [folder 's16/']; % Where do you want to save processed data
outfile = 's16.tif';         % name of the processed files start with ????, its flexible

bbox = [72 34.5; 73 35];   % upper left lower right 1. lon and then lat

% Play around with these parameters
lon = 34;  % Location for basin extraction or sample location
lat = 73.2;
bname = 'B08';    % this is the basin name

%
% % ====== ====== ====== ====== ====== ====== ====== ====== ======
% % ====== ====== ====== ====== ====== ====== ====== ====== ======
% % DONT CHANGE BELOW unless you know what you are going to do.
%
area_info=geotiffinfo(strcat(folder,file));
bbox = area_info.BoundingBox
%2645*2010

[imgBox(1,1), imgBox(1,2)]=map2pix(area_info.RefMatrix,bbox(1),bbox(3));
[imgBox(2,1), imgBox(2,2)]=map2pix(area_info.RefMatrix,bbox(2),bbox(4));

imgBox


