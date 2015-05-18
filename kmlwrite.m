% function kmlwrite(ds,filename)
% Faisal Shahzad, 09.09.2008

filename = 'test.kml'
info=evalin('base','info');


endl = '\n';
descript = 'This is a TecDEM Kml File';

header = ['<?xml version="1.0" encoding="UTF-8"?>' endl ...
    '<kml xmlns="http://earth.google.com/kml/2.2">' endl ...
    '<name>' 'TecDEM 2.0'  '</name>' endl ...
    '<description>' descript  '</description>' endl ...
    '<Document>' endl];

footer = ['</Document>' endl '</kml>' endl];

names = 'Rivers';
descript = 'Extracted Streams';

output = kmlPorcess(ds, names,descript);

fid = fopen(strcat(filename(1:end-4),'.kml'), 'wt');

fprintf(fid,[header output footer]);

fclose(fid);