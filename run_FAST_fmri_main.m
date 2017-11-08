%% RUN ONCE for the experiment
seeds = {'학대', '아픔', '거울', '눈물', '데이트', '사랑'};
% seeds = {'출혈', '게으름', '보석', '환상', '마음', '가족'};

seeds_rand = seeds(randperm(numel(seeds)));

%% Sess 1
fast_fmri_word_generation(seeds_rand{1}, 'practice');

%% 
fast_fmri_transcribe_responses('nosound') % while running fast_fmri_word_generation
fast_fmri_transcribe_responses('only_na') % after running fast_fmri_word_generation

%%
ts = fast_fmri_generate_ts;
fast_fmri_task_main(ts,'practice');

%% Sess 2
fast_fmri_word_generation(seeds_rand(2), 'biopac', 'eyelink');
fast_fmri_task_main(response, 'biopac', 'eyelink');

%% Whole words list & Survey
words = fast_fmri_wholewords;
fast_fmri_survey(words,'practice'); % practice
fast_fmri_survey(words);