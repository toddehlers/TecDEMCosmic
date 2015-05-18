function S = Shielding_Corr_2(rr,cc,tzero1,dem,area_info,bin_ang,m)

[ra,ca ]= size(dem);

S = zeros(ra,ca);

for r = 1+rr:1:ra-rr
    
    disp(strcat('Shielding_Corr_2.m: Percent Done ',num2str(100*r/(ra-rr))));
    
    for c = 1+cc:1:ca-cc
        
        S(r,c)=shld_corr_topo(r,c,rr,cc,tzero1,dem,area_info,bin_ang,m);
        
    end
    
end



