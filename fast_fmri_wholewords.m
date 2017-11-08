function words = fast_fmri_wholewords
%%
savedir = fullfile(pwd, 'data');
SID = input('Subject ID (number)? ', 's');

dat_file{1} = fullfile(savedir, ['b_responsedata_sub' SID '_sess' '1' '.mat']);
dat_file{2} = fullfile(savedir, ['b_responsedata_sub' SID '_sess' '2' '.mat']);
dat_file{3} = fullfile(savedir, ['b_responsedata_sub' SID '_sess' '3' '.mat']);
dat_file{4} = fullfile(savedir, ['b_responsedata_sub' SID '_sess' '4' '.mat']);
dat_file{5} = fullfile(savedir, ['b_responsedata_sub' SID '_sess' '5' '.mat']);

data = cell(41, 5);

for i=1:5
    load(dat_file{i});
    data(:,i)=response;
end

words = data

end



