function [P_nuc, P_mu_stopped, P_mu_fast, Ptot] = calc_dunai(Altitude, Latitude, siz)

% 'Altitude' is the Z matrix: 1 x number of total points, defined in 'siz'
% 'Latitude' is the lat matrix 1 x number of total points

%******************************************
%       Constants
%******************************************

p0_mbar = 1013.25;
b0_K__m = 6.5e-3;
T0_K = 288.15;
g0_m__s2 = 9.80665;
Rd_J__kg = 287.05;
Lambda_mu_fast = 1300;
Lambda_mu_stop = 247;

PNuc0 = 4.16;
PMuonS0 = 0.106;
PMuonF0 = 0.093;

Alkofer = 1;

%******************************************
%       Calculations
%******************************************

fprintf('calc dunai 1\n');
P0 = PNuc0 + PMuonS0 + PMuonF0;
fprintf('P0: %f\n', P0);

f_mu_fast = PMuonF0 / (PNuc0 + PMuonS0 + PMuonF0);
fprintf('f_mu_fast: %f\n', f_mu_fast);

f_mu_stop = PMuonS0 / (PNuc0 + PMuonS0 + PMuonF0);
fprintf('f_mu_stop: %f\n', f_mu_stop);

% Calculate Inclination I
A = (atan(2.*tan(Latitude.*pi./180))).*180./pi;

% Calculate Atmospheric Pressure at Sampling Point
B = p0_mbar.*((1-b0_K__m.*Altitude./T0_K).^(g0_m__s2./Rd_J__kg./b0_K__m));

% Calculate Atmospheric Depth at Sampling Site and at Sea level  [g/cm2]
C = 10.*B./g0_m__s2;

Atmospheric_depth = 10.*p0_mbar./g0_m__s2;
fprintf('Atmospheric_depth: %f\n', Atmospheric_depth);

% Difference in Atmospheric Depth between sampling site and sea level  z(h) [g/cm2]
D = Atmospheric_depth - C;

% Calculate the sea level neutron flux normalised to Inclination = 90°  N1030(I)
E = 0.5555+(0.445./((1+exp(-(A-62.698)./4.1703)).^0.335));

% Calculate mean absorption free path length  Lambda(I)
F = 129.55+19.85./((1+exp(-(A-62.05)./(-5.43))).^3.59);

% Correction of mean absorption free path length for shielding topo
% This step is missing
% AbsorptionFreepath = AbsorptionFreepath * (1 - 1 / (2 * Pi) * (step * Pi / 180) * S * sinT) / (1 - 1 / (2 * Pi) * (step * Pi / 180) * S)


% Calculate Scaling Factors
G = E.*exp(D./F);


Nz_tot = E.*exp(D./F).*(1-f_mu_fast-f_mu_stop)+exp(D./Lambda_mu_stop).*f_mu_stop+(1+0.0581.*Altitude./1000).*f_mu_fast;
Nz_mu_stop = exp(D./Lambda_mu_stop).*Alkofer;

% The term for fast muons was derived after Heisinger. See Schaller EPSL 2002 for explanations.
Nz_mu_fast = 1 + 0.0581 .* Altitude ./ 1000;


P_nuc = P0.*G.*(1-f_mu_fast-f_mu_stop);
P_mu_stopped = P0.*Nz_mu_stop.*f_mu_stop;
P_mu_fast =P0.*Nz_mu_fast.*f_mu_fast;
Ptot = P0.* Nz_tot;


P_nuc = reshape(P_nuc,siz);
P_mu_stopped = reshape(P_mu_stopped,siz);
P_mu_fast = reshape(P_mu_fast,siz);
Ptot = reshape(Ptot,siz);

end
