function desc = calGradient(rgb_im, seg, numRegion)
    
    G = fspecial('gaussian',[4 4],2);
    Ig = imfilter(rgb_im,G,'same');
    [Gmag,Gdir] = imgradient(rgb2gray(Ig));
    
    binNum = 20;
    inter = max(max(Gmag)) / binNum;
    Gmag = int32(Gmag / inter);
   
    binVal = 1:binNum;
    desc = zeros([numRegion binNum]);
    
    cnt = 0;
    ind={};
    for iReg=1:numRegion
        ind{iReg} = seg(:)==iReg;
    end

    for bin=1:binNum
        cnt = cnt + 1;
        I =  (Gmag(:)==binVal(bin)) ;
        for iReg=1:numRegion
            desc(iReg,cnt) = sum(I(ind{iReg}));
        end
    end
    
    tmp = sum(desc, 2);
    desc = desc ./ repmat(tmp(:,:), [1 size(desc,2)]);

end