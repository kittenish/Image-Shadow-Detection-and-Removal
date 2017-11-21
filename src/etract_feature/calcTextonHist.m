function desc  = calcTextonHist(rgb_im, seg, numRegion)
    if ~isa(rgb_im,'double'),
        rgb_im = double(rgb_im)/256;
    end
    gray_im = (rgb_im(:,:,1)+rgb_im(:,:,3))./(rgb_im(:,:,2))+1e-2;
    gray_im = gray_im / max(gray_im(:));
    load('bsd300_128.mat');
    fim = fbRun(fb,gray_im);
    im = assignTextons(fim, textons);
    [hgt wid] = size(im);
    
    binNum = 128;
    binVal = 1:binNum;
    desc = zeros([numRegion binNum]);
    
    cnt = 0;
    ind={};
    for iReg=1:numRegion
        ind{iReg} = seg(:)==iReg;
    end

    for bin=1:binNum
        cnt = cnt + 1;
        I =  (im(:)==binVal(bin)) ;
        for iReg=1:numRegion
            desc(iReg,cnt) = sum(I(ind{iReg}));
        end
    end
    
    tmp = sum(desc, 2);
    desc = desc ./ repmat(tmp(:,:), [1 size(desc,2)]);
end
