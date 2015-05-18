function img = geotiffread(varargin)
% FShahzad, geoquaidian@gmail.com
% 11.09.2011

%disp('geotiffread');
%disp('varargin');
%disp(varargin);

if nargin == 1
    
    fname = varargin{1};
    Tinfo = geotiffinfo(fname);
    imgBox = [1 1; Tinfo.Height Tinfo.Width];
    
elseif nargin == 3
    
    fname = varargin{1};
    Tinfo = geotiffinfo(fname);
    
    if strcmp(varargin{2},'image')
        
        imgBox =  varargin{3};
        
    elseif strcmp(varargin{2},'map')
        
        mapBox =  varargin{3};
        
        [imgBox(1,1), imgBox(1,2)]=map2pix(Tinfo.RefMatrix,mapBox(1),mapBox(3));
        [imgBox(2,1), imgBox(2,2)]=map2pix(Tinfo.RefMatrix,mapBox(2),mapBox(4));

    else
        
        disp('second argument is not correct. exiting');
        img = [];
        return;
        
    end
    
else
    
    disp('not enought input arguments.. exiting');
    img = [];
    return;
    
end


fmt = Tinfo.BitDepth/8;

switch fmt
    
    case {1}
        format = 'uint8';
    case {2}
        format = 'int16';
    case {3}
        format = 'int32';
    case {4}
        format = 'single';
        
end


imgBox = round(imgBox);

w = round(imgBox(2)- imgBox(1))+1;
h = round(imgBox(4)- imgBox(3))+1;

%disp(Tinfo);

fprintf('imgBox: %d\n', imgBox);
fprintf('w: %d, h: %d\n', w, h);
fprintf('file width: %f, file height: %f\n', Tinfo.Width, Tinfo.Height);

maxX = Tinfo.Width * Tinfo.RefMatrix(2,1);
maxY = Tinfo.Height * Tinfo.RefMatrix(1,2);

if (w < 0.0) || (w > Tinfo.Width)
    fprintf('\n\n\nWidth is out of range: %f!\n', w);
    fprintf('Check bounding box parameters!\n');
    fprintf('Max difference allowed: %f pixel (%f degree)\n', Tinfo.Width, maxX);
    error('Bounding box error!')
end

if (h < 0.0) || (h > Tinfo.Height)
    fprintf('\n\n\nHeight is out of range: %f!\n', h);
    fprintf('Check bounding box parameters!\n');
    fprintf('Max difference allowed: %f pixel (%f degree)\n', Tinfo.Height, maxY);
    error('Bounding box error!');
end

if (imgBox(2) > Tinfo.Width)
    fprintf('\n\n\nX2 out of range: %f\n', imgBox(2));
    fprintf('Check bounding box parameters!\n');
    fprintf('Max allowed: %f pixel (%f degree)\n', Tinfo.Width, Tinfo.RefMatrix(3,1) + maxX);
    error('Bounding box error!');
end

if (imgBox(4) > Tinfo.Height)
    fprintf('\n\n\nY2 out of range: %f\n', imgBox(4));
    fprintf('Check bounding box parameters!\n');
    fprintf('Max allowed: %f pixel (%f degree)\n', Tinfo.Height, Tinfo.RefMatrix(3,2) + maxY);
    error('Bounding box error!');
end

img=zeros(w,h,format);

ind = Tinfo.imginfo.StripOffsets;

fid = fopen(fname,'r','ieee-le');

% reading tiff column wise not row wise!

for i = imgBox(1):1:imgBox(2)
    try
        fseek(fid,ind(i),'bof');
        t=fread(fid,Tinfo.Height,format);
        img(i-imgBox(1)+1,:) = t(imgBox(3):imgBox(4));
    catch
        fprintf('error at index: %d\n', i);
        error('Bounding box error!');
    end
end

assignin('base','img',img);
fclose(fid);