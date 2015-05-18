% function flowangCode(area_info)

load_grid_base('caller','DEM');
load_grid_base('caller','FLOW');

prodfac = ShieldingFactor(flowdir,dem,area_info)

figure;
imagesc(real(prodfac))
axis image


