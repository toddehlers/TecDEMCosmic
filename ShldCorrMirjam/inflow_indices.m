function [azimuth, ind] = inflow_indices(inflowmatrix,siz,ind)

[rf, cf] = ind2sub(siz,ind);

%fcodes  = [315 0 45; 270 -1 90; 225 180 135];
fcodes  = [45 45 45; 45 -1 45; 45 45 45];

rr = rf + [-1 -1 -1; 0 0 0; 1 1 1];

cc = cf + [-1 -1 -1; 0 0 0; 1 1 1]';

inda = sub2ind(siz,rr(:),cc(:));

indout=inflowmatrix(inda);

azimuth=fcodes(indout == ind);

ij=rr(indout == ind);
ik=cc(indout == ind);

ind=sub2ind(siz,ij,ik);
