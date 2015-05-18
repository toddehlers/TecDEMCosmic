function output = kmlPorcess(rivers,names,descript)

output = [];
endl = '\n';
splacemark = ['<Placemark>' endl];
eplacemark = ['</Placemark>' endl];
name = ['<name>' names  '</name>' endl ];
desc = ['<description>' descript  '</description>' endl ];


if strcmp(rivers(1).Geometry,'Line')
    
    for id = 1:length(rivers);

        data = [];
        
        for ii = 1:1:length(rivers(id).Lat)
            
            data1=[num2str(rivers(id).Lat(ii)) ',' num2str(rivers(id).Lon(ii))  endl];
            data = [data data1];
            
        end
        
        coords = [endl '<LineString>' endl '<coordinates>' endl data   '</coordinates>' endl '</LineString>' endl];
        styleurl = ['<styleUrl>' strcat('#',num2str(id)) '</styleUrl>'];
        output = [output splacemark name desc  styleurl coords eplacemark];
        
    end
    
end

% sprintf(output)