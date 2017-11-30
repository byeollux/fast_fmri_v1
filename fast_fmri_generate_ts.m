function [ts, isi_iti] = fast_fmri_generate_ts
% 
% function ts = fast_fmri_generate_ts
% 
% To make jittered ISI, ITI and two words series
%
% ts{i}{1} = two words of 'i'th trial
% ts{i}{2} = ISI, blank between words screen
% ts{i}{3} = ITI, blank after rating screen
%
% ts{1} = {{'sw', 'w1'}, [6], [0]} -> no rating, ISI = 6s
% ts{2} = {{'w1', 'w2'}, [6], [6]} -> rating, ISI = 6s, ITI = 6s
%
% ..
%    Copyright (C) 2017  Cocoan lab
% ..
%%
ts = cell(40,1);

SID = input('Subject ID (number)? ', 's');
SessID = input('Session number? ', 's');

savedir = fullfile(pwd, 'data');
dat_file = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);

load(dat_file); 

intervals = repmat([3 4 6 9]', 1, 11); % one column vector becomes 4x11 matrix
for i = 1:size(intervals,2) % size of column = 11 
    intervals(:,i) = intervals(randperm(4),i); % It's a great example of good using :
end

for i = 1:4
    wh_rating(i) = randi(7); % which one of 3 trials will be rated?
end

wh_rating(1) = wh_rating(1)+3;
wh_rating(2) = wh_rating(2)+10;
wh_rating(3) = wh_rating(3)+23;
wh_rating(4) = wh_rating(4)+30;


isi_iti = zeros(44,2);  % make empty matrix

isi_iti(:,1) = intervals(:);

for i = 1:38
    if i == wh_rating(1) || i == wh_rating(2) || i == wh_rating(3) || i == wh_rating(4)
        isi_iti(i,2) = isi_iti(i+1,1);
        isi_iti(i+1,:) = [];
    elseif i == 20
        isi_iti(i,2) = isi_iti(i+1,1);       
        isi_iti(i+1,:) = [];
    end
end

isi_iti(40,1) = 5;  % After the final words, waiting 5s

for i = 1:(numel(response)-1)   % add two words series at the first and second columns of 'ts'
    ts{i} = {{response{i}, response{i+1}}, isi_iti(i,1), isi_iti(i,2)};
end

end