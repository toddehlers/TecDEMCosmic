function open_data_set_cl(loc)
% open_data_set.m 
% This function is used to open any existing project specified by '_INFO.mat'.
% 
% 
% TecDEM: A MATLAB based tool box for understanding tectonics from digital
% elevation models.
% Faisal Shahzad
% TU Bergakademie, Freiberg, Germany
% geoquaidian@gmail.com
% 10.12.12
% 

if ~isempty(loc)

    evalin('base','clear all')
    rest = load(loc);

    rest.info.path = loc(1:end-9);
    r = [rest.area_info.Height rest.area_info.Width];
    
    assignin('base','area_info',rest.area_info);
    assignin('base','info',rest.info);
    assignin('base','r',r);

    disp(strcat('Project_***', rest.info.project_name(1:end-4) ,'***_Loaded successfully.'));

else

    disp ('The Project lcoation is not valid.')

end