function[Va]=flightspeedcutoff(n)

if n>=0
  
    ap=-3.7961;
    bp=25.796;
    
    Va=ap*n^2+bp*n;
else
    
    an=-9.8783;
    bn=-41.787;
    
    Va=an*n^2+bn*n;
end



