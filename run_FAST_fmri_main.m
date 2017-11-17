
%% Sess 1
    %% Resting & Word Generation
    fast_fmri_resting(0.01,'test');       % practice resting
    % fast_fmri_resting(6, 'biopac','eye');       % 6 min restingrara
    fast_fmri_word_generation(seeds_rand{1},'test','biopac','eye');
    % fast_fmri_resting(2, 'biopac','eye')        % 2 min resting

    %% Transcribe
    fast_fmri_transcribe_responses('nosound') % while running fast_fmri_word_generation
    fast_fmri_transcribe_responses('only_na') % after runnin g fast_fmri_word_generation

    %% Thinking and Rating
    [ts, isi_iti] = fast_fmri_generate_ts;
    
    fast_fmri_task_main(ts, isi_iti,'test','practice');
    fast_fmri_task_main(ts, isi_iti, 'test','biopac','eye');

    %% Whole words list & Survey
    words = fast_fmri_wholewords;
    fast_fmri_survey(words,'test');

    %%


%% RUN ONCE for the experiment
seeds = {'학대', '아픔', '거울', '눈물', '데이트', '사랑'};
% seeds = {'출혈', '게으름', '보석', '환상', '마음', '가족'};
seeds_rand = seeds(randperm(numel(seeds)));