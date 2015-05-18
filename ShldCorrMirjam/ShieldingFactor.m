function prodfac = ShieldingFactor(flowdir, dem, area_info, m, myProgressBar)

siz = size(flowdir);

prodfac = ones(siz);

currentCounter = 0.0;
totalSize = siz(1) * siz(2);

for ii = 2:1:siz(1) - 1
    for jj = 2:1:siz(2) - 1
        currentPercentage = currentCounter / totalSize;
        waitbar(currentPercentage, myProgressBar, sprintf('Progress: %2.2f %%', currentPercentage * 100.0));
        currentCounter = currentCounter + 1.0;

        try
            ind = sub2ind(siz,ii,jj);

            [azimuth, nind] = inflow_indices(flowdir,siz,ind);

            dh = dem(nind) - dem(ind);
            dx = area_info.res;

            inclination =  atan(dh./dx);

            prodfac(ii,jj) = (1 - sum(azimuth.* power(sin(inclination),m+1))./360);
        catch
            prodfac(ii,jj) = 1;
        end
    end
end
