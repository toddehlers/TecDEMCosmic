function select_basin_latlon (lat,lon,typ,name,search_radius)

area_info = evalin('base','area_info');
info = evalin('base','info');

if strcmp(typ,'map')
    
    [ra,ca] = map2pix(area_info.RefMatrix,lat,lon);

else
    ca  = lat;
    ra  = lon;
end

fprintf('select_basin_latlon.m: ra: %f (%d), ca: %f (%d)\n', ra, round(ra), ca, round(ca));

% store content of file in variable 'flowdir'
load_grid_base('caller','FLOW')

% store content of file in variable 'dem'
load_grid_base('caller','DEM')

r = size(dem);

numl = numel(flowdir);
from = find(flowdir ~= -1);
to = flowdir(from);
fd = sparse(from,to,1,numl,numl);

max_num_elems = 1;

dem_x_orig = round(ra);
dem_y_orig = round(ca);

dem_x = dem_x_orig;
dem_y = dem_y_orig;

index_pos = sub2ind(r,dem_x,dem_y);

search_length = 1;
d_right = 1;
d_top = 2;
d_left = 3;
d_bottom = 4;
current_direction = d_right;
current_length = 1;
d_counter = 0;

% 2013.07.29, WK: added search radius for location
while true

    fprintf('select_basin_latlon.m: index position: %d, dem_x: %d, dem_y: %d\n', index_pos, dem_x, dem_y);

    id = [index_pos];

    basinmatrix = zeros(r);

    % disp(fd(:, id(1) - 10 : id(1) + 10));

    while ~isempty(id)
        basinmatrix(id(1)) = 1;
        id = [id; find(fd(:,id(1)))];
        id(1) = [];
        max_num_elems = max(max_num_elems, numel(id));
    end

    fprintf('select_basin_latlon.m: max_num_elems: %d\n', max_num_elems);

    if max_num_elems < 20
        fprintf('select_basin_latlon.m: could not find solution, trying different position\n');
        if search_length > search_radius;
            fprintf('could not find solution, try bigger radius\n');
            break;
        end

        fprintf('current pos: dem_x: %d, dem_y: %d, search_length: %d, direction: %d\n', dem_x, dem_y, search_length, current_direction);
        index_pos = sub2ind(r,dem_x,dem_y);

        % WK, 2013.09.16, we use a spiral algorithm to determine the next
        % position:
        % http://stackoverflow.com/questions/3706219/algorithm-for-iterating-over-an-outward-spiral-on-a-discrete-2d-grid-from-the-or
        % http://rosettacode.org/wiki/Spiral_matrix

        switch current_direction
            case d_right
                dem_x = dem_x + 1;
                if current_length == search_length
                    current_length = 1;
                    d_counter = d_counter + 1;
                    current_direction = d_top;
                else
                    current_length = current_length + 1;
                end
            case d_top
                dem_y = dem_y + 1;
                if current_length == search_length
                    current_length = 1;
                    d_counter = d_counter + 1;
                    current_direction = d_left;
                else
                    current_length = current_length + 1;
                end
            case d_left
                dem_x = dem_x - 1;
                if current_length == search_length
                    current_length = 1;
                    d_counter = d_counter + 1;
                    current_direction = d_bottom;
                else
                    current_length = current_length + 1;
                end
            case d_bottom
                dem_y = dem_y - 1;
                if current_length == search_length
                    current_length = 1;
                    d_counter = d_counter + 1;
                    current_direction = d_right;
                else
                    current_length = current_length + 1;
                end
        end

        if d_counter == 2
            d_counter = 0;
            search_length = search_length + 1;
        end
        
    else
        fprintf('select_basin_latlon.m: success\n');
        break;
    end
end


basinmatrix(:,1) = 0;
basinmatrix(:,end) = 0;
basinmatrix(1,:) = 0;
basinmatrix(end,:) = 0;

imagesc(basinmatrix)
savefile = strcat(info.path,['_' name '.mat']);
save(savefile,'basinmatrix','-v7.3');
