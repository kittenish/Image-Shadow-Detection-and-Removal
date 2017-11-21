function desc = calcLabHist(rgb_im, seg, numRegion)
    if ~isa(rgb_im,'uint8'),
        rgb_im = im2uint8(rgb_im);
    end
    
    cform = makecform('srgb2lab');
    im = applycform(rgb_im,cform);
    
    binNum = 50;
    binVal = 0:256/(binNum):256;
    desc = zeros([numRegion binNum*3]);
    
    cnt = 0;
    ind={};
    for iReg=1:numRegion
        ind{iReg} = seg(:)==iReg;
    end
    
    for ch=1:3
        for bin=1:binNum
            cnt = cnt + 1;
            I = im(:,:,ch);
            I = ( (I>=binVal(bin)) & (I<binVal(bin+1)) );
            for iReg=1:numRegion
                desc(iReg, cnt) = sum(I(ind{iReg}));
            end
        end
    end
    
    tmp = sum(desc, 2);
    desc = (desc ./ repmat(tmp(:), [1 size(desc,2)]))*3;
end
