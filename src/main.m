addpath('meanshift');
addpath('libsvm/')
addpath('./libsvm/matlab/');
addpath('./etract_feature/');
addpath('./utils/');

% fid=fopen('UIUC_file.txt');
% i=0;
% while ~feof(fid)
%     aline=fgetl(fid);
%     
%     annotate(aline);
%     i = i + 1
% end

% if i < 2598
%         i = i + 1;
%         continue;
%     end

url = 'data/UIUC/Our_test/original/p2_2.jpg';
[seg, segnum, between, near, centroids, label, grad, texthist] = detect(url);
removal(seg, segnum, between, label, near, centroids, url, grad, texthist);