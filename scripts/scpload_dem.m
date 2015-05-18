function scpload_dem(location_in,areaname_in,typ,bbox,location_out,areaname_out)

if ~exist(location_out, 'dir')
   
    mkdir(location_out);
    
end

if areaname_in ~= 0
    
    fls = strcat(location_in,areaname_in);
    area_info = geotiffinfo(fls);

    fileX1 = area_info.BoundingBox(1,1);
    fileY1 = area_info.BoundingBox(1,2);
    fileX2 = area_info.BoundingBox(2,1);
    fileY2 = area_info.BoundingBox(2,2);

    userX1 = bbox(1,1);
    userY1 = bbox(1,2);
    userX2 = bbox(2,1);
    userY2 = bbox(2,2);

    bbHasErrors = false;

    fprintf('user bounding box: %f, %f, %f, %f\n', userX1, userY1, userX2, userY2);
    fprintf('file bounding box: %f, %f, %f, %f\n', fileX1, fileY1, fileX2, fileY2);
    
    if fileX1 < fileX2
        if (userX1 < fileX1) || (userX1 > fileX2)
            fprintf('bounding box long1 (%f) out of rage: [%f,%f]\n', userX1, fileX1, fileX2);
            bbHasErrors = true;
        end
        if (userX2 < fileX1) || (userX2 > fileX2)
            fprintf('bounding box long2 (%f) out of rage: [%f,%f]\n', userX2, fileX1, fileX2);
            bbHasErrors = true;
        end
    else
        if (userX1 < fileX2) || (userX1 > fileX1)
            fprintf('bounding box long1 (%f) out of rage: [%f,%f]\n', userX1, fileX2, fileX1);
            bbHasErrors = true;
        end
        if (userX2 < fileX2) || (userX2 > fileX1)
            fprintf('bounding box long2 (%f) out of rage: [%f,%f]\n', userX2, fileX2, fileX1);
            bbHasErrors = true;
        end
    end

    if fileY1 < fileY2
        if (userY1 < fileY1) || (userY1 > fileY2)
            fprintf('bounding box lat1 (%f) out of rage: [%f,%f]\n', userY1, fileY1, fileY2);
            bbHasErrors = true;
        end
        if (userY2 < fileY1) || (userY2 > fileY2)
            fprintf('bounding box lat2 (%f) out of rage: [%f,%f]\n', userY2, fileY1, fileY2);
            bbHasErrors = true;
        end
    else
        if (userY1 < fileY2) || (userY1 > fileY1)
            fprintf('bounding box lat1 (%f) out of rage: [%f,%f]\n', userY1, fileY2, fileY1);
            bbHasErrors = true;
        end
        if (userY2 < fileY2) || (userY2 > fileY1)
            fprintf('bounding box lat2 (%f) out of rage: [%f,%f]\n', userY2, fileY2, fileY1);
            bbHasErrors = true;
        end
    end
    
    if bbHasErrors
        error('Bounding box error, see lines above');
    end
    
    rawdem = double(geotiffread(fls,typ,bbox));
    
    fls = strcat(location_out,areaname_out);
   
    savefile = strcat(fls(1:end-4),'_rawDEM.mat');
    save(savefile,'rawdem','-v7.3')
    
    [ny nx] =size(rawdem);
    
        
    res1 = area_info.PixelScale(1);
    res2 = area_info.PixelScale(2);
    
    info.dtheta = -0.45;
    info.path = fls(1:end-4);
    info.project_name = areaname_out;
    res1 = 110000*res1;
    res2 = 110000*res2;
   
    area_info.TiePoints.WorldPoints.Y = bbox(1);
    area_info.TiePoints.WorldPoints.X = bbox(3);
    
    
    area_info.RefMatrix = makerefmat(bbox(1), ...
        bbox(3), ...
        -area_info.PixelScale(1), ...
        area_info.PixelScale(2));
   
    area_info.BoundingBox = bbox;
    
    
%     area_info.RefMatrix = makerefmat(bbox(1), bbox(4),res1,-res2);

    area_info.res(1) = res1;
    area_info.res(2) = res2;
    
    area_info.Height = ny;
    area_info.Width = nx;
    
    assignin('base','info',info);
    assignin('base','area_info',area_info);
    assignin('base','r',[ny nx]);
    assignin('base','res',res1);
    
    savefile = strcat(fls(1:end-4),'_INFO.mat');
    save(savefile,'area_info','info')
    dem_info_write()
    
    
    textfile = strcat(info.path,'_info.txt');
    
    fid=fopen(textfile,'r');
    
    while 1
        tline = fgetl(fid);
        
        if ~ischar(tline),
            
            break
            
        end
        
    end
    
    disp('Digital Elevation Model loaded successfully.');

else
    
    disp('Digital Elevation Model not loaded.');
        
end