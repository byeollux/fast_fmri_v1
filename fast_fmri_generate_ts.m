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
%    Copyright (C) 2017  Wani Woo (Cocoan lab)
% ..
%%
ts = cell(40,1);

SID = input('Subject ID (number)? ', 's');
SessID = input('Session number? ', 's');

savedir = fullfile(pwd, 'data');
dat_file = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);

load(dat_file); 

intervals = repmat([3 4 6 9]', 1, 13); % one column vector becomes 4x13 matrix
for i = 1:size(intervals,2) % size of column = 13, one column has info for 3 trials 
    intervals(:,i) = intervals(randperm(4),i); % It's a great example of good using :
    wh_rating(i) = randi(3); % which one of 3 trials will be rated?
end

isi_iti = zeros(40,3);  % make empty matrix

for i = 1:13
    idx = (3*(i-1)+1):(3*(i-1)+3);     % remainder after divided by 3 = 1,2,3
    isi_iti(idx,1) = intervals(1:3,i); % fill the first column of 'isi_iti' with
                                       % 1~3 rows, 'i'st column of 'intervals'
    isi_iti(idx(wh_rating(i)),2) = intervals(4,i); % 4th row of 'intervals' will be a ITI
end

% concetration condition
concent_iti = [4 6 9];
concent_iti = concent_iti(:,randperm(3));
for i = 1:numel(concent_iti)
    if isi_iti(i*10,2)==0
        isi_iti(i*10,3) = concent_iti(i);
    elseif isi_iti(i*10+1,2)==0
        isi_iti(i*10+1,3) = concent_iti(i);
    else 
        isi_iti(i*10+2,3) = concent_iti(i);
    end
end    


isi_iti(40,1) = 15;  % After the final words, waiting 15s

for i = 1:(numel(response)-1)   % add two words series at the first and second columns of 'ts'
    ts{i} = {{response{i}, response{i+1}}, isi_iti(i,1), isi_iti(i,2), isi_iti(i,3)};
end

end