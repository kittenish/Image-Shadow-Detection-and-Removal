function [hardmap] = findshadow(opt)
    if ~isfield(opt, 'save')
       opt.save = 0;
    end
    if ~isfield(opt, 'adjecent')
       opt.adjecent = 0;
    end
    if ~isfield(opt, 'pairwiseonly')
       opt.pairwiseonly = 0;
    end  
    basename = opt.fn(1:end-4);
    im=imread([opt.dir 'original/' opt.fn]);
    
    %im = (double(im)/255).^(.45).*255;
    
    oim = im;
    org_siz = [size(im, 1) size(im, 2)];
    
    if opt.resize == 0
        resiz_ratio = 1;
    else
        resiz_ratio = 640/org_siz(2);
    end
    im = imresize(oim, resiz_ratio);
    if opt.linearize
        gamma_im = (double(im)/255).^(1/.45);
        im = gamma_im;
    end
    %im = (double(im)/255);
    %im = (double(im)/255).^(1/.45);
    
    try
        load([opt.dir 'cache/' basename '_seg.mat']);
    catch exp1
        disp 'Segmenting'
        [dummy seg] = edison_wrapper(im, @RGB2Luv, ...
            'SpatialBandWidth', 9, 'RangeBandWidth', 15, ...
             'MinimumRegionArea', 200);
         seg = seg + 1;
         save([opt.dir 'cache/' basename '_seg.mat'], 'seg');
    end
    
    numlabel = length(unique(seg(:)));
    
    try
        load([opt.dir 'cache/' basename '_single.mat']);
    catch exp1
        disp 'Single region feature'
        
        %load('cache/model_our.mat', 'model');
        labhist = calcLabHist(im, seg, numlabel);
        texthist = calcTextonHistNoInv(im, seg, numlabel);
        hsv = calHsv(im, seg, numlabel, 10);
        testdata=[labhist, texthist, hsv];
        testlabel = ones(numlabel, 1);
        save([opt.dir 'cache/' basename '_single.mat'], 'testdata', 'testlabel');
    end
    %load(opt.unaryClassifier, 'model');
    load(opt.unaryClassifier, 'model');
    disp 'Single region classification'
    %[err, s]=svmclassify(testdata, testlabel, model);
    %s
    [s]=svmpredict(testlabel, testdata, model);
    ss = double(sign(s));
    ssmap=(1-ss(seg))/2;
    min(min(ssmap))  
    try
        load([opt.dir 'cache/' basename '_pair.mat']);
    catch exp1
        
        disp 'Pair region feature'
        
        shapemean = calcShapeMean(seg, numlabel);
        area = shapemean.area;
        centroids = shapemean.center;
        rgbmean = calcRGBMean(im, seg, numlabel);
        texthist = calcTextonHist(im, seg, numlabel);
        labhist = calcLabHist(im, seg, numlabel);
        d_text=dist_chi2(texthist', texthist');
        d_lab =dist_chi2(labhist', labhist');
        
        ind = [];
        finalvector = zeros(numlabel,numlabel, 8);
        
        for i=1:numlabel
            for j=1:numlabel
                if i==j , continue; end
                r = rgbmean(i,:)./rgbmean(j,:);
                dist = norm(centroids(i,:) - centroids(j,:))/sqrt(sqrt(area(i)*area(j)));
                finalfeature = [d_text(i,j), d_lab(i,j), ...
                    r, dist, abs(r(1)./r(2)-1)*10, abs(r(2)./r(3)-1)*10];
                finalvector(j,i,:)=finalfeature;
            end
        end
        finalvector = reshape(finalvector, [numlabel*numlabel 8]);
        g_diff = zeros(numlabel, numlabel);
        g_same = zeros(numlabel, numlabel);
        save([opt.dir 'cache/' basename '_pair.mat'], 'finalvector', 'shapemean');
    end
    load(opt.binaryClassifier, 'diffmodel', 'samemodel');
    disp 'Pair region classification'
    [err, s1]=svmclassify(finalvector, zeros(numlabel*numlabel, 1) , diffmodel);
    [err, s2]=svmclassify(finalvector, zeros(numlabel*numlabel, 1), samemodel);  
    s1 = reshape(s1, [numlabel numlabel]);
    s2 = reshape(s2, [numlabel numlabel]);
    k1=100; k2=200;
    t1 = sort(s1(:));t1(isnan(t1))=[];
    t2 = sort(s2(:));t2(isnan(t2))=[];
    thresh1 = t1(max(1, length(t1(:))-k1)); thresh1 = max(.6, thresh1);
    thresh2 = t2(max(1, length(t2(:))-k2)); thresh2 = max(.6, thresh2);
    %  thresh1 = t1(max(1, length(t1(:))-k1)); thresh1 = max(0, thresh1);
    %  thresh2 = t2(max(1, length(t2(:))-k2)); thresh2 = max(0, thresh2);
    %  thresh1 = 0;
    %  thresh2 = 0;
    %FIXME!!!!!!!!!!!!
    if strcmp('models/model_pair_our.mat', opt.binaryClassifier)
    for i=1:numlabel
        for j=1:numlabel
            if i==j , continue; end
            w = sqrt(shapemean.area(i)*shapemean.area(j));
            g_diff(i,j) = w*s1(j,i);
            g_same(i,j) = w*s2(j,i);
        end
    end
    else
    for i=1:numlabel
        for j=1:numlabel
            if i==j , continue; end
            w = sqrt(shapemean.area(i)*shapemean.area(j));
            g_diff(i,j) = w*s1(i,j);
            g_same(i,j) = w*s2(i,j);
        end
    end
    end
    
    nNodes = numlabel;
    nStates = 2;
    adj1 = logical(sparse(nNodes,nNodes));
    adj2 = logical(sparse(nNodes,nNodes));
    
    m=buildAdjacentMatrix(seg, numlabel);
    
    for i=1:numlabel
        for j=1:numlabel
            if opt.adjecent, 
                if ~m(i,j) continue; end;  
            end;
            if s1(i,j)>thresh1
                adj1(i,j)=1;
            end
            if s2(i,j)>thresh2
                adj2(i,j)=1;
            end
        end
    end
    
    nodePot = zeros(nNodes,nStates);
    w1 = 1;
    if ~opt.pairwiseonly
        for i=1:numlabel
            wi = w1 * shapemean.area(i);
            nodePot(i,1) = -s(i)*wi;
            nodePot(i,2) = s(i)*wi;
        end
    end
    
    if 1
        sc = shapemean.center;
        nim = im;
        [gx gy] = gradient(double(seg));
        eim = (gx.^2+gy.^2)>1e-10;
        
        t = nim(:,:,1); t(eim)=0; nim(:,:,1)=t;
        t = nim(:,:,2); t(eim)=0; nim(:,:,2)=t;
        t = nim(:,:,3); t(eim)=0; nim(:,:,3)=t;
        f3 = figure(3);
        clf;
        %imshow(nim);
        %hold on
        for i=1:numlabel
        for j=1:numlabel
            if ~adj1(i,j) && ~adj2(i,j), continue; end
            if s1(i,j)>thresh1
                plot([sc(i,1) sc(j,1)], [sc(i,2) sc(j,2)], 'b');
                plot(sc(i,1), sc(i,2), 'bo')
            elseif s2(i,j)>thresh2
                plot([sc(i,1) sc(j,1)], [sc(i,2) sc(j,2)], 'r');
            end
        end
        end
       %print(f3, '-dpsc', [opt.dir 'cache/' basename '_graph.eps']);
       if ~opt.save
        figure(3)
        imshow(nim);
        hold on
        for i=1:numlabel
        for j=1:numlabel
            if ~adj1(i,j) && ~adj2(i,j), continue; end
            if s1(i,j)>thresh1
                plot([sc(i,1) sc(j,1)], [sc(i,2) sc(j,2)], 'b');
                plot(sc(i,1), sc(i,2), 'bo')
            elseif s2(i,j)>thresh2
                plot([sc(i,1) sc(j,1)], [sc(i,2) sc(j,2)], 'r');
            end
        end
        end
        figure(6), imagesc(s(seg))
        figure(4), imagesc(seg)
       else
           imwrite(nim,[opt.dir 'segment/' basename '_segment.png']);
      end
    end
    
    edgeStruct1 = UGM_makeEdgeStruct_directed(adj1,nStates);
    edgeStruct2 = UGM_makeEdgeStruct_directed(adj2,nStates);
    edgePot = [];
    w3=1;
    w2=2;
    for e = 1:edgeStruct1.nEdges
        n1 = edgeStruct1.edgeEnds(e,1);
        n2 = edgeStruct1.edgeEnds(e,2);
        %nodePot(n1,1) = nodePot(n1,1)+ w2*(g_diff(n1, n2)-g_diff(n2, n1));
        %nodePot(n2,2) = nodePot(n2,2)+ w2*(g_diff(n1, n2)-g_diff(n2, n1));
        nodePot(n1,1) = nodePot(n1,1)+ w2*g_diff(n1, n2);
        nodePot(n1,2) = nodePot(n1,2)- w2*g_diff(n1, n2);
        nodePot(n2,1) = nodePot(n2,1)- w2*g_diff(n1, n2);
        nodePot(n2,2) = nodePot(n2,2)+ w2*g_diff(n1, n2);
    end
        
    for e = 1:edgeStruct2.nEdges
        n1 = edgeStruct2.edgeEnds(e,1);
        n2 = edgeStruct2.edgeEnds(e,2);

        edgePot(:,:,e) = [g_same(n1, n2) 0;...
            0, g_same(n1, n2) ].*[w3 1; 1 w3];
    end
    
    if ~isempty(edgePot)
        Decoding = UGM_Decode_ModifiedCut(nodePot,edgePot,edgeStruct2);
    else
        Decoding = double(sign(s))+1;
    end
    
    hardmap = Decoding(seg)-1;
    
    if ~opt.save
        figure(4)
        ss = double(sign(s));
        ssmap=(1-ss(seg))/2;
        imshow(double(ssmap))
        
        figure(5)
        imshow(1-double(hardmap))
        
        figure(1);
        imshow(im);
    else
        imwrite(hardmap,[opt.dir 'binary/' basename '_binary.png']);	
        ss = double(sign(s));
        ssmap=(1-ss(seg))/2;       
        imwrite(1-ssmap,[opt.dir 'unary/' basename '_unary.png']);
        save([opt.dir 'cache/' basename '_detect.mat'],'hardmap','ssmap');
        
        shadowim = hardmap;

        tmp = ones(size(im));
        tmp2 = cat(3, zeros([size(shadowim) 2]), 0.5*shadowim);

        mask = logical(repmat(shadowim, [1 1 3]));
        tmp(mask) = tmp2(mask);
        %tmp = shadowim.*ones(size(shadowim));
        %tmp = cat(3, zeros([size(shadowim) 2]), shadowim);

        grayim = im2double(repmat(rgb2gray(im), [1 1 3]));
        im2 = (grayim+tmp)/2;
        imwrite(im2, [opt.dir 'mask/' basename '_mask.png']);
    end

    RegionScore = s;
    DiffScore = s1;
    SameScore = s2;
    DiffAdj = adj1;
    SameAdj = adj2;
    save([opt.dir 'cache/' basename '_everything.mat'], 'RegionScore', 'DiffScore', 'SameScore', 'DiffAdj', 'SameAdj', 'seg', 'im', 'hardmap', 'ssmap');
    
    % get the pairing information consistent with the final detection.
    [shadow, non_shadow] = find(adj1 == 1);
    
    pair = [];
    
    num_pair = numel(non_shadow);
    for i = 1:num_pair
       if Decoding(non_shadow(i))==1 && Decoding(shadow(i)) == 2
           pair = [pair; non_shadow(i) shadow(i)];
       end
    end
   
    save([opt.dir 'cache/' basename '_finalpair.mat'], 'pair');
end
