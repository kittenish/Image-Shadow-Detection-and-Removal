function [desc] = calcShapeMean(seg, numRegion)
    stats = regionprops(seg, 'Area', 'Centroid');
    desc.area = cat(1, stats.Area);
    desc.center = cat(1, stats.Centroid);
    
end
