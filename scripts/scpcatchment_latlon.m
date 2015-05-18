function scpcatchment_latlon(lat,lon)

load_grid_base('base','ADN');
load_grid_base('base','FLOW');
load_grid_base('base','CON');

netwk_order_ind  = evalin('base','netwk_order_ind');
str_net  = evalin('base','str_net');
bsngrd  = evalin('base','str_map');
flowdir = evalin('base','flowdir');
tzero = evalin('base','tzero1');

disp('Watershed Extraction Started');

for k = 1:1:length(netwk_order_ind)

    strid = netwk_order_ind(k).ind;

    for j = 1:1:length(strid)

        r = str_net(strid(j)).rowid;
        c = str_net(strid(j)).colid;
        ind = sub2ind(size(tzero),r,c);
        bsngrd(ind) = k + i*strid(j);

    end
end


to = find(tzero == 0);

assignin('base','bsngrd',bsngrd);
%
lsto = length(to);
pst = 1;
for a = 1:1:lsto

    percent = round(100*a/lsto);

    if percent == pst*1
%         pause(0.00001);
        pst = pst +1;
        disp(strcat(num2str(percent),' Percent of calculation done\r'));
    end

    output=flow_stream_basin(to(a));
    if flowdir(output(end)) ~= -1
        bsngrd(output) = bsngrd(flowdir(output(end)));
    else
        bsngrd(output) = bsngrd(output(end));
    end
end
assignin('base','bsngrd',bsngrd);
pause(0.00001);

scpcatchment_matrix(td)

disp('Watershed Extraction Finished');
% add_comm_line();

evalin('base','clear bsngrd flowdir netwk_order_ind str_map str_net tzero1 eorder boundary basinmatrix lt td')
end