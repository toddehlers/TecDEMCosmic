function scpstrahlere_segments(lt)
% gridding_full.m 
% This function extract the drainge network and assigns strahler stream 
% order to each stream. It also assigns area, elevation and length of
% stream to this structure.
% 
% TecDEM: A MATLAB based tool box for understanding tectonics from digital
% elevation models.
% Faisal Shahzad
% TU Bergakademie, Freiberg, Germany
% geoquaidian@gmail.com
% 
% 
disp('Drainage Network Extraction Started');
load_grid_base('base','FLOW');

scpdrainage_extract_area(lt);

try
parea = evalin('base','parea');
catch
    return
end

info = evalin('base','info');

noval  =-1;

str_map = noval * parea;

assignin('base','str_map',str_map);

str_net = struct('id',[],'rowid',[],'colid',[],'order',[]);
netwk_order_ind = struct('ind',[]);
i = 1;

while i

    create_pzero(noval);
    to1 = find(str_map == noval);
    pause(0.0001)
    if ~isempty(to1)
        [str_net netid] = prepare_network(str_net,to1,i);
        netwk_order_ind(i).ind = netid;
        
        disp(strcat(num2str(length(netid)),' Streams of Strahler order # ', num2str(i)));
        
        str_map = evalin('base','str_map');
        i = i +1;
    else
        i = 0;
    end

end

savefile = strcat(info.path,'_ADN.mat');
save(savefile,'str_net','netwk_order_ind','str_map','-v7.3');

disp(strcat('A total of .',num2str(length(str_net)),' streams were exctracted successfully.'));
disp('Strahler orders assigned successfully');

assignin('base','str_net',str_net);
assignin('base','netwk_order_ind',netwk_order_ind);

disp('Drainage Network extraction finished');
% add_comm_line();

evalin('base','clear parea flowdir pzero str_map str_net netwk_order_ind lt');