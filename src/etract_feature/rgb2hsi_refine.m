function hsi = rgb2hsi_refine(x)
    
    F=im2double(x);
    r=F(:,:,1);
    g=F(:,:,2);
    b=F(:,:,3);
    
    I=(r+g+b)/3;
    V1 = - sqrt(1/6)*r - sqrt(1/6)*g + sqrt(2/3)*b;
    V2 = sqrt(1/6)*r - sqrt(2/3)*g;
    S = sqrt(V1.*V1 + V2.*V2);
    H = (tan(V2./V1)).^(-1);
    
    I = (I - min(min(I))) ./ (max(max(I)) - min(min(I)));
    H(isinf(H)) = max(H(~isinf(H)));
    H(isnan(H)) = max(H(~isnan(H)));
    H = (H - min(min(H))) ./ (max(max(H)) - min(min(H)));
    
    hsi=cat(3,H,S,I);

end

