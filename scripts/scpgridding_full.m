function scpgridding_full()

disp('Calculating Flow directions using D8 algorithm.');

load_grid_base('caller','DEM');

spflow= flowdir_single(dem); % In TecDEM version 2.0 it uses flowdir_single from topotoolbox

[nfrom nto] = find(spflow);

flowdir = -1*ones(size(dem));
flowdir(nfrom) = nto;

% 
info = evalin('base','info');
flowlen = ones(size(dem));
savefile = strcat(info.path,'_LEN.mat');
save(savefile,'flowlen','-v7.3')

disp('Flow lengths along possible flow directions are saved.');

savefile = strcat(info.path,'_FLOW.mat');
% save content of variable 'flowdir' into binary matlab HDF file
save(savefile,'flowdir','-v7.3')
disp('Finished flow directions calculations');
disp('Calculating Concave flow directions')
count_inflow(flowdir);

