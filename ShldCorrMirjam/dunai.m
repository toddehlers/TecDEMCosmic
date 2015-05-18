% ----------
% Program entry point
% Start here for the second step:
% 2. Calculate shielding factor
%
% The first step is to find the basin (file scpTecDEM.m)
% ----------

clear all
clc

loc = 'data/Uganda/s04/s04_INFO.mat';
% loc = '/Users/mirjam/Desktop/TecDEM_2/data/bolivia/s09/s09_INFO.mat';
% loc = '/Users/fshahzad/Dropbox/personal/TecDEM_25/data/bolivia/s09/s09_INFO.mat';
open_data_set_cl(loc)


bname = 'B04';
bin_ang = 5; % Bin size for angles, try to give in multiple of 5
rr = 10; % No. of pixels to search along rows 90* 10
cc = 10; % No. of pixels to search along cols
m  = 2.3;

% This sets the number of steps for the shielding calculation.
% 360° / numOfDirectionSteps = angle
numOfDirectionSteps = 360;

% This sets the skipping factor for the actual topography
% If the calculation takes too much time, increase this value
topoStep = 1;

% ====== ====== ====== ====== ====== ====== ====== ====== ======
% ====== ====== ====== ====== ====== ====== ====== ====== ======
% DONT CHANGE BELOW unless you know what you are going to do.
load_grid_base('caller','DEM');
load_grid_base('caller',bname); % Give basin name here
load_grid_base('caller','FLOW');
load_grid_base('caller','CON');

refMAT = area_info.RefMatrix;

%disp(refMAT);
%disp(refMAT(2));
%disp(refMAT(4));


load_grid_base('caller',strcat('DUN_', bname ));

P_nuc = zeros(size(dem));
P_mu_stopped = zeros(size(dem));
P_mu_fast = zeros(size(dem));
Ptot = zeros(size(dem));
shFac = zeros(size(dem));

P_nuc2 = zeros(size(dem));
P_mu_stopped2 = zeros(size(dem));
P_mu_fast2 = zeros(size(dem));
Ptot2 = zeros(size(dem));
sFactors2 = zeros(size(dem));

sFactors3 = zeros(size(dem));

%if ~exist('Ptot','var')

    siz = size(dem);
    inds = 1:1:numel(dem);
    [r c] = ind2sub(siz,inds);
    
    Altitude = dem(inds);
    lat = refMAT(3) + (c-1)*refMAT(4);

    myProgressBar = waitbar(0,'Calculating...');

    %fprintf('date and time (start method 1): %s\n', datestr(now));
    %[P_nuc, P_mu_stopped, P_mu_fast, Ptot] = calc_dunai(Altitude, lat, siz);
    %shFac = ShieldingFactor(flowdir, dem, area_info, m, myProgressBar);   % Dunai Method
    %fprintf('date and time (finish method 1): %s\n\n\n', datestr(now));
    

    fprintf('date and time (start method 2): %s\n', datestr(now));
    [P_nuc2, P_mu_stopped2, P_mu_fast2, Ptot2, sFactors2] =  processPointsInCatchment(dem, basinmatrix, area_info, numOfDirectionSteps, m, topoStep, myProgressBar);
    fprintf('date and time (finish method 2): %s\n\n\n', datestr(now));


    %fprintf('date and time (start method 3): %s\n', datestr(now));
    %sFactors3 =  shieldMethod3(dem, basinmatrix, area_info, myProgressBar);
    %fprintf('date and time (finish method 3): %s\n\n\n', datestr(now));


    % info = evalin('base','info');
    % savefile = strcat(info.path,['_DUN_' bname '.mat']);
    % save(savefile,'P_nuc', 'P_mu_stopped', 'P_mu_fast', 'Ptot','shFac','-v7.3')
    
    close(myProgressBar);
%end

% shFac=tshfac;
% shFac = 1-shFac;

ind = basinmatrix == 1; % this is list of coordinates inside the extracted basin.

avg_height = mean(dem(ind));
fprintf('\nmean elevation: %f\n', avg_height);

avg_P_nuc = mean(P_nuc(ind));
fprintf('\navg_P_nuc: %f\n', avg_P_nuc);

avg_P_mu_stopped = mean(P_mu_stopped(ind));
fprintf('avg_P_mu_stopped: %f\n', avg_P_mu_stopped);

avg_P_mu_fast = mean(P_mu_fast(ind));
fprintf('avg_P_mu_fast: %f\n', avg_P_mu_fast);

avg_Ptot = mean(Ptot(ind));
fprintf('avg_Ptot: %f\n', avg_Ptot);

avg_shFac = mean(shFac(ind));
fprintf('\navg_shFac 1: %f, 2: %f, 3: %f\n', avg_shFac, mean(sFactors2(ind)), mean(sFactors3(ind)));

avg_P_nuc_shFac = mean(P_nuc(ind) .* shFac(ind));
fprintf('avg_P_nuc_shFac 1: %f, 2: %f\n', avg_P_nuc_shFac, mean(P_nuc2(ind)));

avg_P_mu_stopped_shFac = mean(P_mu_stopped(ind) .* shFac(ind));
fprintf('avg_P_mu_stopped_shFac 1: %f, 2: %f\n', avg_P_mu_stopped_shFac, mean(P_mu_stopped2(ind)));

avg_P_mu_fast_shFac = mean(P_mu_fast(ind) .* shFac(ind));
fprintf('avg_P_mu_fast_shFac 1: %f, 2: %f\n', avg_P_mu_fast_shFac, mean(P_mu_fast2(ind)));

avg_Ptot_shFac = mean(Ptot(ind) .* shFac(ind));
fprintf('avg_Ptot_shFac 1: %f, 2: %f\n\n', avg_Ptot_shFac, mean(Ptot2(ind)));

total_basin_area_KM2 = (sum(basinmatrix(:)) .* area_info.res .* area_info.res)/(1000*1000);
fprintf('total_basin_area_KM2: %f\n', total_basin_area_KM2);


figure
Ptot2(basinmatrix==0) = NaN;
imagesc(Ptot2)
axis image
colorbar
title('Proudction rate')

figure
sFactors2(basinmatrix==0) = NaN;
imagesc(sFactors2)
axis image
colorbar
title('Shielding factor')

edgeBasin = edge(basinmatrix, 'canny');
indEdge = find(edgeBasin);

figure
dem(indEdge) = NaN;
imagesc(dem)
axis image
colorbar
title('DEM')
