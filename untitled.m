% repmat(img, 1, 1, 3)


savedir = fullfile(pwd, 'data');

[fname, start_line, SID] = subjectinfo_check(savedir, 'survey'); % subfunction
if exist(fname, 'file'), load(fname, 'survey'); end

survey.exp_starttime = datestr(clock, 0); % date-time: timestamp
survey.surveyfile = fullfile(savedir, ['d_surveydata_sub' SID '.mat']);
survey.dat{1,1} = 11;


% initial save of trial sequence and data
if exist (fname, 'file')
    save(survey.surveyfile, 'survey', '-append');
else
    survey.dat = cell(40, 5);  % 40x5 cell
    save(survey.surveyfile, 'survey');
end

survey.dat{1,2} = 11;
save(survey.surveyfile, 'survey', '-append');