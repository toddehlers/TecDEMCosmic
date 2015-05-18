function Sheliding_Corr_2
S = zeros(size(dem));

for r = 100;
    
    for c = 100;
        
        S(r,c)=shld_corr_topo(r,c,rr,cc,tzero1,dem,area_info,bin_ang);
        
    end
    
end



