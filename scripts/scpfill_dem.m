function scpfill_dem()

disp('DEM Filling is started');

load_grid_base('caller','rawDEM');

rawdem(rawdem == -9999) = nan;

rawdem(isnan(rawdem)) = -inf;

dem = imfill(rawdem,8,'holes');

info = evalin('base','info');
savefile = strcat(info.path,'_DEM.mat');
save(savefile,'dem','-v7.3')

disp('DEM filling is finished');

end