function tiff_info=geotiffinfo(fname)
% FShahzad, geoquaidian@gmail.com
% 11.09.2011
% Should work with TecDEM, 
% you might not get desired results if used for purpose other than TecDEM.
imginfo = imfinfo(fname);

%disp('geotiffinfo');
%disp('imginfo');
%disp(imginfo);

tiff_info.Filename = imginfo.Filename;
tiff_info.FileModDate = imginfo.FileModDate;
tiff_info.FileSize = imginfo.FileSize;
tiff_info.Format = imginfo.Format;
tiff_info.FormatVersion = imginfo.FormatVersion;
tiff_info.Width = imginfo.Height;
tiff_info.Height = imginfo.Width;

tiff_info.BitDepth = imginfo.BitDepth;
tiff_info.ColorType = imginfo.ColorType;
tiff_info.GCS = imginfo.GeoAsciiParamsTag;

tiff_info.PixelScale = imginfo.ModelPixelScaleTag;

tiff_info.TiePoints.ImagePoints.Row = 0.5;
tiff_info.TiePoints.ImagePoints.Col = 0.5;

tiff_info.TiePoints.WorldPoints.X = imginfo.ModelTiepointTag(5);
tiff_info.TiePoints.WorldPoints.Y = imginfo.ModelTiepointTag(4);

BBOX = zeros(2,2);

BBOX(1) = imginfo.ModelTiepointTag(5);
BBOX(3) = imginfo.ModelTiepointTag(4);

tiff_info.RefMatrix = makerefmat(BBOX(1), ...
                      BBOX(3), ...
                      -imginfo.ModelPixelScaleTag(2), ...
                      imginfo.ModelPixelScaleTag(1));

[x,y]=pix2map(tiff_info.RefMatrix,tiff_info.Height,tiff_info.Width);

BBOX(2) = x;
BBOX(4) = y;


tiff_info.BoundingBox = BBOX;

tiff_info.imginfo = imginfo;


