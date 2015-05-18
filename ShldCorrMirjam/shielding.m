% shielding.m
%
% M-file to calculate topographic shielding for all pixels in a given watershed.
% Acts on a bunch of grids that must be created in ARC/INFO, see web site text
% for information. The scheme is as follows: for a given pixel of interest, polar
% coordinates relative to this pixel are assigned to each other pixel in the image.
% The resulting r,azimuth,elevation triplets are sorted by azimuth into 5-degree bins. 
% The pixel in each bin with the highest angular elevation is taken to be the horizon
% elevation for that azimuth bin. The shielding factor for each bin is then calculated
% by integrating over an obstructed sector of 5 degrees width and this angular 
% elevation in height (see http://depts.washington.edu/cosmolab/math for more info). 
% Although hokey, this procedure appears to be adequately accurate for the vast 
% majority of exposure geometries. This does not consider telescoping of the mean 
% free path length on steeply dipping surfaces. 
%
% May require user modifications pertaining to variable names, etc. to run. 
%
% This takes many hours to run for watersheds of even moderate size. 
%
% Greg Balco
% UW Cosmogenic Isotope Lab
% September, 2001
%
% Not guaranteed to work in any way whatsoever. 

% clear all

% load the necessary data. In this case, all the input grids have already 
% been stored as MATLAB files. Modify as needed. 

disp('Loading data...')
load_grid_base('base','DEM');
load_grid_base('base','B09');
load_grid_base('base','CON');

elv = dem;
wsheds = basinmatrix;
screen = tzero1;
% 
% load elv.txt -ascii
% load wsheds.txt -ascii
% load xgrid.txt -ascii
% load ygrid.txt -ascii
% load screen.txt -ascii

bin_d = 5;

bin_r = bin_d*2*pi/360;

% big loop to do multiple watersheds. Assumes that the grid "wsheds" has 
% integers in it indicating which watershed each point is in. This results 
% in separate output grids for each watershed. Modify as needed. 

for wshed_tag = [1];

% scorekeeping switch

q = 0;

% initialize shielding matrix

clear s_factor
s_factor = zeros(size(elv));

% Consider each pixel 

%disp(['Starting loop for watershed ' int2str(wshed_tag)])
t = clock;
disp([int2str(t(1)) '/' int2str(t(2)) '/' int2str(t(3)) '   ' int2str(t(4))...
		 ':' int2str(t(5)) ':' num2str(t(6))]);

for row = 1:size(wsheds,1);

   for col = 1:size(wsheds,2);

      if wsheds(row,col) == wshed_tag;
			
		 clear t_screen t_elv t_x t_y r theta indices posx negx velv

		 % everything takes place in this if statement

         % scorekeeping switch

         q = q+1;

		 if q/100 == round(q/100)
			disp(['Watershed ' int2str(wshed_tag)]);
			disp(['Pixel ' int2str(q)]);
			tic
		 end;
         % find current coords

         [currentx, currenty]    = pix2map(area_info.RefMatrix,row,col);
         
%          currentx = xgrid(row,col);
% 
%          currenty = ygrid(row,col);
% 
          currentz = elv(row,col);
% 

         % at this point we clip according to screen
         % also keep pixels within 10 of current point
         % then kill off pixels-below; unwrap and clean

         t_screen = screen;

         t_screen(row-10:row+10,col-10:col+10) = ones(21);
% 
         indices = find(elv < currentz);
         
         t_screen(indices) = zeros(size(indices));
         
         % reuse variable indices
         
         indices = find(t_screen == 1);
         
         t_elv = elv(indices);
         [r,c] = ind2sub(size(elv),indices);
         
         [t_x, t_y]    = pix2map(area_info.RefMatrix,r,c);
         
        
%          t_x = xgrid(indices);
% 
%          t_y = ygrid(indices);
% 
%          % construct r
% 
         r = sqrt((t_x-currentx).^2+(t_y-currenty).^2);
% 
         r(find(r==0)) = 10000;
% 
%          % construct theta which is the azimuth...
% 
         theta = zeros(size(r));
% 
         posx = find(t_x > currentx);
% 
         theta(posx) = acos((t_y(posx)-currenty)./r(posx));
% 
         negx = find(t_x <= currentx);
% 
         theta(negx) = (2*pi) - acos((t_y(negx)-currenty)./r(negx));
% 
%          % elevation angle 
% 
         velv = atan((t_elv - currentz)./r);
% 
%          % now we have to sort into azimuth bins...
% 
%          % this step is the time-consuming part.  
% 
         horiz = zeros(1,72);
% 
         bin = ceil(theta/bin_r);
% 
         for a = 1:72;

            % must consider case where no cells are in bin -- 

            mvelv = max(velv(find(bin == a)));

            if ~isempty(mvelv);

               horiz(a) = mvelv;

            end;

         end;
% 
         % now calculate the shielding factor -- 

         % integration formula

         S = (bin_r/(2*pi)) .* (sin(horiz).^3.3);

         % note don't subtract from 1 - giving shielded fxn not free fxn

         s_factor(row,col) = sum(S);

         if q/100 == round(q/100);disp(['Pixel time: ' num2str(toc)]);end

      end;

   end;

end;


eval(['save shield' int2str(wshed_tag) 's_factor'])

% end big loop

end;
