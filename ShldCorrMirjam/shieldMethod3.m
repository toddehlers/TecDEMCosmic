function [ sFactors3 ] = shieldMethod3( dem, basinmatrix, area_info, myProgressBar )
%SHIELDMETHOD3 A third method to calculate the shileding factor
%   http://depts.washington.edu/cosmolab/math

bin_d = 1;
bin_r = bin_d*2*pi/360;
angle = 360 / bin_d;

[imgWidth, imgHeight] = size(dem);
scaleX = area_info.PixelScale(1);
scaleY = area_info.PixelScale(2);

sFactors3 = zeros(imgWidth, imgHeight);

% Adoption for new script:
elv = dem;
xgrid = repmat(1:imgHeight, imgWidth, 1);
ygrid = repmat((1:imgWidth)', 1, imgHeight);
screen = zeros(imgWidth, imgHeight);

currentCounter = 0.0;
totalSize = double(imgWidth * imgHeight);

for py = 1:imgHeight
    for px = 1:imgWidth
        currentPercentage = currentCounter / totalSize;
        waitbar(currentPercentage, myProgressBar, sprintf('Progress: %2.2f %%', currentPercentage * 100.0));
        currentCounter = currentCounter + 1.0;

        if basinmatrix(px, py) == 1 % Point is inside the basin


            % find current coords
            row = px;
            col = py;
            currentx = xgrid(row,col) * scaleX;
            currenty = ygrid(row,col) * scaleY;
            currentz = elv(row,col);


            % at this point we clip according to screen
            % also keep pixels within 10 of current point
            % then kill off pixels-below; unwrap and clean

            t_screen = screen;
            t_screen(row-10:row+10,col-10:col+10) = ones(21);
            indices = find(elv < currentz);
            t_screen(indices) = zeros(size(indices));
            % reuse variable indices

            indices = find(t_screen == 1);
            t_elv = elv(indices);
            t_x = xgrid(indices) * scaleX;
            t_y = ygrid(indices) * scaleY;

            % construct r

            r = sqrt((t_x-currentx).^2+(t_y-currenty).^2);
            r(find(r==0)) = 10000;

            % construct theta which is the azimuth...

            theta = zeros(size(r));
            posx = find(t_x > currentx);
            theta(posx) = acos((t_y(posx)-currenty)./r(posx));
            negx = find(t_x <= currentx);
            theta(negx) = (2*pi) - acos((t_y(negx)-currenty)./r(negx));

            % elevation angle 

            velv = atan((t_elv - currentz)./r);

            % now we have to sort into azimuth bins...

            % this step is the time-consuming part.  

            horiz = zeros(1,angle);
            bin = ceil(theta/bin_r);

            for a = 1:angle;

                % must consider case where no cells are in bin -- 

                mvelv = max(velv(find(bin == a)));
                if ~isempty(mvelv);
                    horiz(a) = mvelv;
                end;
            end;

            % now calculate the shielding factor -- 

            % integration formula

            S = (bin_r/(2*pi)) .* (sin(horiz).^3.3);

            % note don't subtract from 1 - giving shielded fxn not free fxn

            sFactors3(row,col) = sum(S);

        end
    end
end


end
