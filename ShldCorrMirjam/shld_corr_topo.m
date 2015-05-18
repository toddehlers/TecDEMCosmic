function S=shld_corr_topo(r,c,rr,cc,tzero1,dem,area_info,bin_ang,m)
% This is based upong the sheilding.m file given by mirjam.

rind = r-rr:1:r+rr;

cind = c-cc:1:c+cc;

tind = tzero1(rind,cind) == 0;

[rtind, ctind]= find(tind == 1);

spt_complex = rr+1i*cc;
ept_complex = rtind+1i*ctind;

dif_complex = ept_complex - spt_complex;

%theta = rad2deg(angle(dif_complex));
distance = abs(dif_complex)*area_info.res;
% sdem = dem(rind,cind)- dem(r,c);
vtheta = rad2deg(atan(dem(tind)./distance));

[n,xmid] = hist(vtheta,0:bin_ang:360-bin_ang);
[n1,xout] = histc(vtheta,xmid);

horiz = zeros(size(n1));

for a = 1:length(horiz);
%     % must consider case where no cells are in bin --
    
    mvtheta = max(vtheta(xout == a));
    
    if ~isempty(mvtheta);
        
        horiz(a) = mvtheta;

    end;

end

S = sum([(deg2rad(bin_ang:bin_ang:360)/(2*pi))].*[(sin(deg2rad(horiz)).^m)]');