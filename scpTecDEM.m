% ----------
% Program entry point
% Start here for the first step:
% 1. Find basin
%
% The second step is to determin the shielding factor (file dunai.m)
% ----------

clc
clear all

% TecDEM execution scripts
scpAddpathlist();

folder = 'data/Uganda/'; % Folder location to read in the big mosaic file or input data
file = 'DEM_Tif.tif'; % File name in the above mentioned folder

outfolder = [folder 's04/']; % Where do you want to save processed data
outfile = 's04.tif';         % name of the processed files start with ????, its flexible

% upper left (lat, long lower right
bbox = [ 46.9 3.0; 46.5 3.2 ];
%bbox = [ -64.0  -19.5;  -63.5  -20.0];
% First is latitude and then longitude

% Play around with these parameters
% Location for basin extraction or sample location

lat = 46.739029;
lon = 3.074758;

% lon = -63.7300;  
% lat = -19.7300;
bname = 'B04';    % this is the basin name

% 2013.07.29, WK, search radius for basin, in pixels
search_radius = 10;

%
% % ====== ====== ====== ====== ====== ====== ====== ====== ======
% % ====== ====== ====== ====== ====== ====== ====== ====== ======
% % DONT CHANGE BELOW unless you know what you are going to do.
%
%area_info=geotiffinfo(strcat(folder,file));
%bbox = area_info.BoundingBox

fprintf('The full path is: %s%s\n', folder, file);

scpload_dem(folder,file,'map',bbox,outfolder,outfile);

scpfill_dem(); % Filling holes in DEM
scpgridding_full(); % finding flow direction
scpupslope_area2(); % Finding upslope area
scpstrahlere_segments(1); % 1 sq km threshold to extract drainage network

select_basin_latlon (lat,lon,'map',bname,search_radius);

% % % ====== ====== ====== ====== ====== ====== ====== ====== ======
% % % ====== ====== ====== ====== ====== ====== ====== ====== ======
% % % JUST IN CASE YOU WANT TO HAVE A QUICK LOOK ON THE BASIN
% %
% 
% % 
load_grid_base('base',bname)
figure
imagesc(basinmatrix);
axis image
colorbar
title('EXTRACTED BASIN')
