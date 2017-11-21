function [seg, segnum, between, near, centroids, label, grad, texthist]=detect(url)

%im = imread('/Users/mac/Desktop/Image Processing/project/data/SBU-shadow/SBU-Test/ShadowImages/983314s.jpg');
%im = imread('/Users/mac/Desktop/Image Processing/project/data/SBU-shadow/SBU-Test/ShadowImages/3392986913_d12c3b0aa2_z.jpg');
%im = imread('/Users/mac/Desktop/Image Processing/project/data/SBU-shadow/SBU-Test/ShadowImages/42eda42s-960.jpg');

im = imread(url);

%load('data/SBU-shadow/SBU-Test/annotation/983314s.mat', 'seg', 'shadow', 'lit', 'segnum');
%load('data/SBU-shadow/SBU-Test/annotation/3392986913_d12c3b0aa2_z.mat', 'seg', 'shadow', 'lit', 'segnum');
%load('data/SBU-shadow/SBU-Test/annotation/42eda42s-960.mat', 'seg', 'shadow', 'lit', 'segnum');
%load('data/UIUC/Our_test/annotation/p21_1.mat', 'seg', 'shadow', 'lit', 'segnum');
% try
%     load('data/UIUC/Our_test/annotation/lssd355.mat', 'seg', 'shadow', 'lit', 'segnum');
% catch exp1
    disp 'Segmenting'
    [dummy seg] = edison_wrapper(im, @RGB2Luv, ...
       'SpatialBandWidth', 9, 'RangeBandWidth', 15, ...
       'MinimumRegionArea', 200);
    seg = seg + 1;
    segnum = max(max(seg));
% end
disp 'Detect'
hsi = calHsi(im, seg, segnum);
hsv = calHsv(im, seg, segnum);
ycbcr = calYcbcr(im, seg, segnum);
%labhist = calcLabHist(im, seg, segnum);
texthist = calcTextonHist(im, seg, segnum);
grad = calGradient(im, seg, segnum);

shapemean = calcShapeMean(seg, segnum);
area = shapemean.area;
centroids = shapemean.center;
epsilon=0.01;

% ycbcr(:,1) = (ycbcr(:,1)- min(ycbcr(:,1)) + epsilon) / (max(ycbcr(:,1)) - min(ycbcr(:,1)));
% hsv(:,3) = (hsv(:,3) - min(hsv(:,3)) + epsilon) / (max(hsv(:,3)) - min(hsv(:,3)));
ycbcr(:,1) = ycbcr(:,1) / max(ycbcr(:,1));
hsv(:,1) = hsv(:,1) / max(hsv(:,1));

between = zeros([segnum, segnum]);
for i = 1:size(between, 1)
    for j = 1:size(between, 2)
        %between(i, j) = sum((grad(i,:)-grad(j,:)).^2./(grad(i,:)+grad(j,:)+epsilon)) + sum((texthist(i,:)-texthist(j,:)).^2./(texthist(i,:)+texthist(j,:)+epsilon));
        distance = [centroids(i,1), centroids(i,2); centroids(j,1), centroids(j,2)];
        distance = sqrt((distance(1,1)-distance(2,1))^2 + (distance(1,2)-distance(2,2))^2) / max(size(im, 1), size(im, 2));
        between(i, j) = sum(abs(grad(i,:) - grad(j,:))) + sum(abs(texthist(i,:) - texthist(j,:))) + distance;
        if i == j
            between(i,j) = 100;
        end
    end
end

nim = im;
[gx gy] = gradient(double(seg));
eim = (gx.^2+gy.^2)>1e-10;
t = nim(:,:,1); t(eim)=0; nim(:,:,1)=t;
t = nim(:,:,2); t(eim)=0; nim(:,:,2)=t;
t = nim(:,:,3); t(eim)=0; nim(:,:,3)=t;
% imshow(nim);
% hold on;

near = zeros([1, segnum]);
for i = 1:segnum
    [value, near(1, i)] = min(between(i,:));
    j = near(1, i);
    plot([centroids(i,1) centroids(j,1)], [centroids(i,2) centroids(j,2)], 'b');
    %text(centroids(i,1),centroids(i,2),[ num2str(centroids(i,1)) ,  num2str(centroids(i,2))])
    %between(i, j) = sum(abs(grad(i,:) - grad(j,:))) + sum(abs(texthist(i,:) - texthist(j,:)));
end

% ll = zeros([1, length(near)]) + 255;
% for i = 1:length(shadow)
%     j = shadow(i);
%     ll(j) = 0;
% end
hh = zeros([3, length(near)]);
for i = 1:length(near)
    j = near(i);
        max_hsv = max(hsv(i,3), hsv(j,3));
        min_hsv = min(hsv(i,3), hsv(j,3));
        max_ycbcr = max(ycbcr(i,1), ycbcr(j,1));
        min_ycbcr = min(ycbcr(i,1), ycbcr(j,1));
        max_hsi = max((hsi(i,1)+1/255)/(hsi(i,3)+1/255), (hsi(j,1)+1/255)/(hsi(j,3)+1/255));
        min_hsi = min((hsi(i,1)+1/255)/(hsi(i,3)+1/255), (hsi(j,1)+1/255)/(hsi(j,3)+1/255));
        %hh(1, i) = min_hsv/max_hsv;
        hh(2, i) = min_ycbcr/max_ycbcr;
        hh(1, i) = min_hsi / max_hsi;
        %hh(3, i) = ll(i) == ll(j);
end


x = reshape(hsi(:,1)./hsi(:,3), [size(hsi,1),1]);
[idx,center] = kmeans(x,2);
c_std = zeros([2,1]);
temp = idx == 1;
c_std(1,1) = std(x(temp));
temp = idx == 2;
c_std(2,1) = std(x(temp));
if center(1,1) > center(2,1)
    center = sort(center);
    temp = c_std(1,1);
    c_std(1,1) = c_std(2,1);
    c_std(2,1) = temp;
end


%%

label = zeros([1, segnum]) + 255;
ycbcr_copy = ycbcr;
n_nonshadow = segnum;
avg_y = mean(ycbcr(:,1));
flag = 0;
t_hsi = hsi(:,1) ./ hsi(:,3);
level = graythresh(t_hsi);

for i = 1:segnum
    
    if ycbcr(i,1) < avg_y * 0.6
        label(i) = 0;
        ycbcr_copy(i,:) = 0;
        n_nonshadow = n_nonshadow - 1;
        flag = flag + 1;
    end
end

%%
refuse = zeros([1, segnum]);

while 1
    update = 0;
    new = 0;
    max_v = 0;
    for i = 1:segnum
        val = hsi(i,1) / hsi(i, 3);
        temp1 = normcdf((val-center(2,1))/c_std(2,1));
        temp2 = normcdf(-(val-center(1,1))/c_std(1,1));
        if temp2 < temp1 && refuse(i) == 0 && label(i) == 255
            if temp1 > max_v
                
                new = i;
                max_v = temp1;
                update = 1;
            end
        end
            
    end
    if update == 0 || max_v < 0.0028
        break;
    end
    label(new) = 0;
    j = near(new);
    vali = hsi(i,1) / hsi(i, 3);
    valj = hsi(j,1) / hsi(j, 3);
    if ((vali-center(2,1))/c_std(2,1)) - ((valj-center(2,1))/c_std(2,1)) > 3 
        refuse(j) = 1;
        label(j) = 255;
        
    end
    ycbcr_copy(i,:) = 0;
    n_nonshadow = n_nonshadow - 1;
    flag = flag + 1;
end

%%
for i = 1:segnum
    if label(i) ~= 255
        continue
    end
    j = near(i);
    max_hsv = max(hsv(i,3), hsv(j,3));
    min_hsv = min(hsv(i,3), hsv(j,3));
    max_ycbcr = max(ycbcr(i,1), ycbcr(j,1));
    min_ycbcr = min(ycbcr(i,1), ycbcr(j,1));
    same = min_hsv / max_hsv + min_ycbcr / max_ycbcr + hh(1,i);
    
    if same > 2.5 && label(j) == 0
        hh(1,i)
        same
        label(i) = 0;
    end
end
%%
imshow(label(seg))
%%
% while flag < segnum
%     
%     new = 0;
%     new_value = 0;
%     new_2 = 0;
%     new_2_value = 0;
%     distance = 1e10;
%     miao = 0;
%     ff = 0;
%     for i = 1:segnum
%         if label(i) ~= 1
%             continue
%         end
%         j = near(i);
%         max_hsv = max(hsv(i,3), hsv(j,3));
%         min_hsv = min(hsv(i,3), hsv(j,3));
%         max_ycbcr = max(ycbcr(i,1), ycbcr(j,1));
%         min_ycbcr = min(ycbcr(i,1), ycbcr(j,1));
%         max_hsi = max(hsi(i,1)/hsi(i,3), hsi(j,1)/hsi(j,3));
%         min_hsi = min(hsi(i,1)/hsi(i,3), hsi(j,1)/hsi(j,3));
%         same = hh(1,i) + min_ycbcr / max_ycbcr;
%         
%         if label(j) ~= 1
%             if same > center(2, 1) - 2*c_std(2, 1)
%                 faith = 1 / normcdf((same-center(2,1))/c_std(2,1));
%                 if between(i,j)*faith < distance
%                     new = i;
%                     new_value = label(j);
%                     new_2 = 0;
%                     new_2_value = 0;
%                     distance = between(i,j)*faith;
%                     ff = faith;
%                 end
%             end 
%             if  same < center(1, 1) + 2*c_std(1, 1)
%                 faith = 1 / normcdf(-(same-center(1,1))/c_std(1,1));
%                 if between(i,j)*faith < distance
%                     new = i;
%                     new_value = abs(255-label(j));
%                     new_2 = 0;
%                     new_2_value = 0;
%                     distance = between(i,j)*faith;
%                     ff = faith;
%                 end       
%             end
%         else
%             if same > center(1, 1) + 2*c_std(1, 1)
%                 ;
%             else
%                 if hsi(i,1)/hsi(i,3) > hsi(j,1)/hsi(j,3) %hsv(i,3) < hsv(j,3) && ycbcr(i,1) < ycbcr(j,1)
%                     faith = 1 / normcdf(-(same-center(1,1))/c_std(1,1));
%                     if between(i,j)*faith < distance
%                         new = i;
%                         new_value = 0;
%                         new_2 = j;
%                         new_2_value = 255;
%                         distance = between(i,j)*faith;
%                         ff = faith;
%                     end
%                     
%                 else% hsv(i,3) > hsv(j,3) && ycbcr(i,1) > ycbcr(j,1)
%                     faith = 1 / normcdf(-(same-center(1,1))/c_std(1,1));
%                     if between(i,j)*faith < distance
%                         new = i;
%                         new_value = 255;
%                         new_2 = j;
%                         new_2_value = 0;
%                         distance = between(i,j)*faith;
%                         ff = faith;
%                     end         
%                 end
%             end
%         end
%     end
%     
%     if distance ~= 1e10
%         label(new) = new_value;
%         
%         
%             ycbcr_copy(new,:) = 0;
%             n_nonshadow = n_nonshadow - 1;
%         
%         if new_2 ~= 0
%             label(new_2) = new_2_value;
%             
%                 ycbcr_copy(new_2,:) = 0;
%                 n_nonshadow = n_nonshadow - 1;
%                 flag = flag + 1;
%         end
%         
%         if label(near(1, new)) == label(new)
%             plot([centroids(new,1) centroids(near(1, new),1)], [centroids(new,2) centroids(near(1, new),2)], 'b');
%         else
%             
%         
%             plot([centroids(new,1) centroids(near(1, new),1)], [centroids(new,2) centroids(near(1, new),2)], 'r');
%         end
%         flag = flag + 1;
%         miao = 1;
%     end
%    
%         
%         avg_y = sum(ycbcr_copy(:,1)) / double(n_nonshadow);
%         
%         for i = 1:segnum
%             if label(i) ~= 1
%                 continue
%             end
%             if ycbcr(i,1) < avg_y * 0.6
%                 label(i) = 0;
%                 ycbcr_copy(i,:) = 0;
%                 n_nonshadow = n_nonshadow - 1;
%                 flag = flag + 1;
%                 miao = 1;
%                 
%             end
%         end
%     
%     if miao == 0
%         avg_y = sum(ycbcr(:,1)) / double(segnum);
%         max_temp = 0;
%         min_temp = 0;
%         min_y = 10;
%         max_y = 10;
%         for i = 1:segnum
%             if label(i) ~= 1
%                 continue
%             end
%             if abs((hsi(i,1) / hsi(i,3) - center(1,1))/c_std(1,1)) < min_y
%                 min_temp = i;
%                 min_y = abs(hsi(i,1) / hsi(i,3) - center(1,1));
%             end
%             if abs((hsi(i,1) / hsi(i,3) - center(2,1))/c_std(2,1)) < max_y
%                 max_temp = i;
%                 max_y = abs(hsi(i,1) / hsi(i,3) - center(2,1));
%             end
%         end
%         
%         if max_y < min_y && max_temp~=0
%             
%             label(max_temp) = 0;
%             ycbcr_copy(max_temp,:) = 0;
%             n_nonshadow = n_nonshadow + 1;
%             flag = flag + 1;
%         else
%             label(min_temp) = 255;
%             ycbcr_copy(min_temp,:) = 0;
%             n_nonshadow = n_nonshadow + 1;
%             flag = flag + 1;
%         end
%     end
% end
% 
% 
end