function [P_nuc2, P_mu_stopped2, P_mu_fast2, Ptot2, sFactors2] = processPointsInCatchment(dem, basinmatrix, area_info, numOfDirectionSteps, m, topoStep, myProgressBar)
%PROCESSPOINTSINCATCHMENT Calculate shielding factor for all points
%   Uses the Dunai Method and code from the VisualBasic Script
 
% size in pixels inside the geotiff image
[imgWidth, imgHeight] = size(dem);

sFactors2 = zeros(imgWidth, imgHeight);

P_nuc2 = zeros(imgWidth, imgHeight);
P_mu_stopped2 = zeros(imgWidth, imgHeight);
P_mu_fast2 = zeros(imgWidth, imgHeight);
Ptot2 = zeros(imgWidth, imgHeight);


% area_info contains all the information from the geotiff image
scaleX = area_info.PixelScale(1);
scaleY = area_info.PixelScale(2);
longitude = area_info.RefMatrix(6);
latitude = area_info.RefMatrix(3);
latitudeStep = area_info.RefMatrix(4);

% This array contains the maximum angle for each direction
maxThetaForEachDirection = zeros(numOfDirectionSteps, 1);

% Constants

p0_mbar = 1013.25; % Standard Pressure at sea level
b0_K__m = 6.5e-3;
T0_K = 288.15; % Standard sea level surface temperature
g0_m__s2 = 9.80665; % Erdbeschleunigung
Rd_J__kg = 287.05;
Lambda_mu_fast = 1300;
Lambda_mu_stop = 247;

PNuc0 = 4.16;
PMuonS0 = 0.106;
PMuonF0 = 0.093;

Allkover = 1.0;

% Total Quartz 10Be SLHL Production Rate [atoms/g/y]
ProdTotal = PNuc0 + PMuonS0 + PMuonF0;
f_mu_fast = PMuonF0 / (PNuc0 + PMuonS0 + PMuonF0);

f_mu_stop = PMuonS0 / (PNuc0 + PMuonS0 + PMuonF0);

fprintf('width: %d, height: %d\n', imgWidth, imgHeight);

stats = regionprops(basinmatrix, 'BoundingBox');
BB =  stats.BoundingBox;
bb_xmin = floor(BB(2));
bb_xmax = ceil(BB(2) + BB(4));
bb_ymin = floor(BB(1));
bb_ymax = ceil(BB(1) + BB(3));

currentCounter = 0.0;
totalSize = (bb_xmax - bb_xmin + 1.0) * (bb_ymax - bb_ymin + 1.0);

fprintf('bb: xmin: %f, xmax: %f, ymin: %f, ymax: %f\n', bb_xmin, bb_xmax, bb_ymin, bb_ymax);

for py = bb_ymin:1:bb_ymax
    for px = bb_xmin:1:bb_xmax
        currentPercentage = currentCounter / totalSize;
        waitbar(currentPercentage, myProgressBar, sprintf('Progress: %2.2f %%', currentPercentage * 100.0));
        currentCounter = currentCounter + 1.0;

        if basinmatrix(px, py) == 1 % Point is inside the basin
            currentHeight = dem(px, py);
            maxThetaForEachDirection = zeros(numOfDirectionSteps, 1); % Reset theta counter

            for row = bb_ymin:topoStep:bb_ymax
                for col = bb_xmin:topoStep:bb_xmax
                    height = dem(col, row);
                    if height > currentHeight % Point above basin level
                        realX = (px - col) * scaleX;
                        realY = (py - row) * scaleY;
                        dist = hypot(realX, realY);

                        theta = atan((height - currentHeight) / dist);

                        direction = round(((numOfDirectionSteps - 1) * (atan2(realX, realY) + pi) / (2 * pi)) + 1);

                        if direction < 1
                            direction = 1;
                        else if direction > numOfDirectionSteps
                            direction = numOfDirectionSteps;
                        end

                        if theta > maxThetaForEachDirection(direction, 1)
                            maxThetaForEachDirection(direction, 1) = theta;
                        end
                    end % height
                end % col
            end % row
            S = 0.0;
            sin_T = 0.0;

            for i = 1:1:numOfDirectionSteps
                 % Check if there is topography that contributes to the shielding for each direction
                if maxThetaForEachDirection(i, 1) > 0
                    sin_T = sin(maxThetaForEachDirection(i, 1));
                    if sin_T > 0
                        S = S + (sin_T ^ (m + 1));
                    end
                end
            end

            % Original code: S = 1 - 1 / (2 * Pi) * (step * Pi / 180) * S
            % But we don't use angle step, we use number of steps!
            S = 1.0 - (S / (numOfDirectionSteps)); % normalize
            sFactors2(px, py) = S;
            
            
            % A Calculate Inclination I
            Inclination = atan(2 * tan((latitude + (py * latitudeStep)) * pi / 180)) * 180 / pi;

            % B Calculate Atmospheric Pressure at Sampling Point
            Pressure = p0_mbar * (1.0 - b0_K__m * currentHeight / T0_K) ^ (g0_m__s2 / Rd_J__kg / b0_K__m);

            % C Calculate Atmospheric Depth at Sampling Site and at Sea level  [g/cm2]
            DepthAtm = 10 * Pressure / g0_m__s2;
            DepthSealevel = 10 * p0_mbar / g0_m__s2;

            % D Difference in Atmospheric Depth between sampling site and sea level  z(h) [g/cm2]
            DepthDifference = DepthSealevel - DepthAtm;

            % E Calculate the sea level neutron flux normalised to Inclination = 90°  N1030(I)
            NeutronFluxSealevel = 0.5555 + (0.445 / ((1.0 + exp(-(Inclination - 62.698) / 4.1703)) ^ 0.335));

            % F Calculate mean absorption free path length  Lambda(I)
            AbsorptionFreepath = 129.55 + 19.85 / ((1.0 + exp(-(Inclination - 62.05) / (-5.43))) ^ 3.59);

            % Correction of mean absorption free path length for shielding topo
            AbsorptionFreepath = AbsorptionFreepath * (1.0 - (S * sin_T / numOfDirectionSteps)) / (1.0 - (S / numOfDirectionSteps));
            % AbsorptionFreepath = AbsorptionFreepath * (1 - 1 / (2 * Pi) * (step * Pi / 180) * S * sinT) / (1 - 1 / (2 * Pi) * (step * Pi / 180) * S)

            % G Calculate Scaling Factors
            ScalingFactorNeutrons = NeutronFluxSealevel * exp(DepthDifference / AbsorptionFreepath) * (1.0 - f_mu_fast - f_mu_stop);

            ScalingFactorStoppedMuons = exp(DepthDifference / Lambda_mu_stop) * f_mu_stop * Allkover;
            % The term for fast muons was derived after Heisinger. See Schaller EPSL 2002 for explanations.
            ScalingFactorFastMuons = (1.0 + 0.0581 * currentHeight / 1000.0) * f_mu_fast;

            ScalingFactorTotal = ScalingFactorNeutrons + ScalingFactorStoppedMuons + ScalingFactorFastMuons;

            P_nuc2(px, py) = ProdTotal * ScalingFactorNeutrons;
            P_mu_stopped2(px, py) = ProdTotal * ScalingFactorStoppedMuons;
            P_mu_fast2(px, py) = ProdTotal * ScalingFactorFastMuons;
            Ptot2(px, py) = ProdTotal * ScalingFactorTotal;

        end % basinmatrix
    end % px
end % py

% close(myProgressBar);

end
