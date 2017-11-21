function desc = hist_match(original, match)
    
    original = double(original);
    binNum = 50;
    binVal = 0:1/(binNum):1;
    desc = zeros([size(original, 1), 1]);
    o_hist = zeros(50, 1);
    
    for bin = 1:size(o_hist, 1)
        oo = (original >= binVal(bin)) & (original < binVal(bin+1));
        o_hist(bin, 1) = sum(oo);
    end
    
    o_hist = o_hist ./ size(original,1);
    
    G=[];              
    for i = 1:binNum
        G=[G sum(match(1:i))]; 
    end
    
    S=[];              
    for i = 1:binNum
        S=[S sum(o_hist(1:i))]; 
    end
    
    index = zeros([binNum, 1]);
    for i = 1:binNum
        tmp{i} = G - S(i);
        tmp{i} = abs(tmp{i});        
        [a index(i)] = min(tmp{i});   
    end

    for i = 1:size(desc, 1)
        o_bin = ceil(original(i, 1) / double(1.0/50));
        if o_bin == 0
            o_bin = 1;
        end
        off = o_bin * double(1.0/50) - original(i, 1);
        desc(i,1) = index(o_bin) * double(1.0/50) - off;   
   end

end