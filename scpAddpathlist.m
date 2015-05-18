function scpAddpathlist(varargin)
d = dir(pwd);
addpath(pwd,0)
ns = strcat(pwd,' added in path list.');
disp('TecDEM Started:');
disp(ns);

if sum([d.isdir])>2
    ind = find([d.isdir]);
    ind(1:2) = [];
    for i = 1:1:length(ind)

        if strcmp(computer,'PCWIN')
            addpath(strcat(pwd,'\',d(ind(i)).name),0)
            ns = strcat(pwd,'\',d(ind(i)).name,' added in path list.');
        else
            addpath(strcat(pwd,'/',d(ind(i)).name),0)
            ns = strcat(pwd,'/',d(ind(i)).name,' added in path list.');
        end

        disp(ns);

    end

end

disp('TecDEM loaded successfully.');