function m = buildAdjacentMatrix(seg, numlabel)
    m = zeros(numlabel, numlabel);
    [dx, dy] = gradient(double(seg));
    I = abs(dx)+abs(dy);
    w = size(I, 2);
    h = size(I, 1);
    for i=1:h
    for j=1:w
        if I(i,j)>0
            r1=max(i-1, 1):min(i+1, h);
            r2=max(j-1, 1):min(j+1, w);
            alladj = unique(seg(r1,r2))';
            for k1=alladj
            for k2=alladj
                if k1~=k2
                    m(k1,k2)=1;
                    m(k2,k1)=1;
                end
            end
            end
        end
    end
    end
end
