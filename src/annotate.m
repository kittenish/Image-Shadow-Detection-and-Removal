function annotate(aline)
    %%
%     s = regexp(aline, '/', 'split');
%     if strcmp(s{4}, 'ShadowImages')
%         im = imread(aline);
%         file_name = [s{1},'/',s{2},'/',s{3},'/annotation/',s{5}];
%         file_name = [file_name(1:length(file_name)-4), '.mat'];
%         disp 'Segmenting'
%         [dummy seg] = edison_wrapper(im, @RGB2Luv, ...
%             'SpatialBandWidth', 9, 'RangeBandWidth', 15, ...
%             'MinimumRegionArea', 200);
%          seg = seg + 1;
%          s{4} = 'ShadowMasks'
%          mask_name = [s{1},'/',s{2},'/',s{3},'/',s{4},'/',s{5}];
%          mask_name = [mask_name(1:length(mask_name)-4), '.png'];
%          mask = imread(mask_name);
%          shadow = [];
%          lit = [];
%          segnum = max(max(seg));
%          temp = zeros(2, segnum);
%          for i = 1:size(mask, 1)
%              for j = 1:size(mask, 2)
%                  if mask(i,j) == 0
%                      temp(1, seg(i,j)) = temp(1, seg(i,j)) + 1;
%                  else
%                      temp(2, seg(i,j)) = temp(2, seg(i,j)) + 1;
%                  end
%              end
%          end
%          for i = 1:size(temp, 2)
%              if temp(1, i) <= temp(2, i)
%                  shadow = [shadow, i];
%              else
%                  lit = [lit, i];
%              end
%          end
%          save(file_name, 'seg', 'shadow', 'lit', 'segnum');
%     end
    
    %%
    s = regexp(aline, '/', 'split');
    if strcmp(s{3}, 'Our_test') && strcmp(s{4}, 'original')
        aline
        im = imread(aline);
        file_name = [s{1},'/',s{2},'/',s{3},'/annotation/',s{5}];
        file_name = [file_name(1:length(file_name)-4), '.mat'];
        disp 'Segmenting'
        [dummy seg] = edison_wrapper(im, @RGB2Luv, ...
            'SpatialBandWidth', 9, 'RangeBandWidth', 15, ...
            'MinimumRegionArea', 200);
         seg = seg + 1;
         s{4} = 'gt';
         mask_name = [s{1},'/',s{2},'/',s{3},'/',s{4},'/',s{5}];
         mask_name = [mask_name(1:length(mask_name)-4), '.png'];
         mask = imread(mask_name);
         mask = imresize(mask, [size(im,1), size(im,2)]);
         shadow = [];
         lit = [];
         segnum = max(max(seg));
         temp = zeros(2, segnum);
         for i = 1:size(mask, 1)
             for j = 1:size(mask, 2)
                 if mask(i,j) == 0
                     temp(1, seg(i,j)) = temp(1, seg(i,j)) + 1;
                 else
                     temp(2, seg(i,j)) = temp(2, seg(i,j)) + 1;
                 end
             end
         end
         for i = 1:size(temp, 2)
             if temp(1, i) <= temp(2, i)
                 shadow = [shadow, i];
             else
                 lit = [lit, i];
             end
         end
         save(file_name, 'seg', 'shadow', 'lit', 'segnum');
    end
end