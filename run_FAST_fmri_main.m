seeds_rand = wgdata.seeds;
%% LAPTOP1 - Resting & Word Generation ====================================
%   fast_fmri_resting(0.01,'test');       % practice resting
    fast_fmri_word_generation('' ,'practice');   % recording test
    
    %% first time
    fast_fmri_resting(6,'biopac','eye');       % 6 min resting
%   fast_fmri_resting(0.2,'biopac');       % 6 min resting

        %% WORD GENERATION + 2m RESTING
        fast_fmri_word_generation(seeds_rand,'biopac','eye');
%       fast_fmri_word_generation(seeds_rand,'eye');
        
        %% THINKING AND RATING
        [ts, isi_iti] = fast_fmri_generate_ts;
        fast_fmri_task_main(ts, isi_iti,'biopac','eye');
%         fast_fmri_task_main(ts, isi_iti);
        
        
        
%% LAPTOP2 - Transcribe ===================================================
    fast_fmri_transcribe_responses('nosound') % while running fast_fmri_word_generation
    
    %%     
    fast_fmri_transcribe_responses('only_na') % after running fast_fmri_word_generation
    
    %%
    fast_fmri_transcribe_responses('response_n', [8]) % playing sound only a few specific trials
    
            %% if you want to revise already written items.
            savedir = fullfile(pwd, 'data');            
            SID = sprintf('F087');
            SessID = input('Session number? ', 's');  
            save(fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']),'response');

            %%             
            N = input('¼öÁ¤ÇÒ Çà?    ','s');
            content = input('¼öÁ¤ÇÒ ³»¿ë?    ','s');
            dat_file = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);          
            load(dat_file);
            response{str2double(N),1} = content;            
            save(fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']),'response');
            
%             save(fullfile(savedir, ['d_surveydata_subF073.mat']),'survey');

            
%% SURVEY 
    words = fast_fmri_wholewords;           % subjectID = F010

    fast_fmri_survey(words);


    
    
    
    
    
      
   

%% RUN ONCE for the experiment
rng('shuffle');
seeds = {'ÇÐ´ë', '°Å¿ï', '´«¹°','°¡Á·'};
seeds_rand = seeds(randperm(numel(seeds))) 
% seeds_rand = {'´«¹°','°¡Á·','ÇÐ´ë','°Å¿ï'};   

%% SEEDWORDS for 2ND PARTICIPATION
i = 21;



seeds_rand  = {'È¯»ó'    '¾ÆÇÄ'    '¸¶À½'    '»ç¶û'; %1
    '»ç¶û'    '¾ÆÇÄ'    'È¯»ó'    '¸¶À½'; 
    '»ç¶û'    'È¯»ó'    '¾ÆÇÄ'    '¸¶À½';
    'È¯»ó'    '¾ÆÇÄ'    '¸¶À½'    '»ç¶û';
    '¸¶À½'    '¾ÆÇÄ'    'È¯»ó'    '»ç¶û';
    '¾ÆÇÄ'    '»ç¶û'    'È¯»ó'    '¸¶À½'; % F058
    '»ç¶û'    '¸¶À½'    'È¯»ó'    '¾ÆÇÄ'; % F059
    'È¯»ó'    '¾ÆÇÄ'    '»ç¶û'    '¸¶À½'; % F061
    '»ç¶û'    '¸¶À½'    '¾ÆÇÄ'    'È¯»ó'; % F067
    '¸¶À½'    'È¯»ó'    '»ç¶û'    '¾ÆÇÄ'; % 69
    'È¯»ó'    '»ç¶û'    '¸¶À½'    '¾ÆÇÄ'; % 70
    'È¯»ó'    '»ç¶û'    '¾ÆÇÄ'    '¸¶À½'; % 74
    '¸¶À½'    '¾ÆÇÄ'    '»ç¶û'    'È¯»ó'; % 76
    'È¯»ó'    '¸¶À½'    '»ç¶û'    '¾ÆÇÄ'; % 78
    '¾ÆÇÄ'    '¸¶À½'    'È¯»ó'    '»ç¶û'; % 79
    '»ç¶û'    '¾ÆÇÄ'    '¸¶À½'    'È¯»ó'; % 80
    '¸¶À½'    '»ç¶û'    'È¯»ó'    '¾ÆÇÄ'; % 81
    '¾ÆÇÄ'    'È¯»ó'    '»ç¶û'    '¸¶À½'; % 84
    '¾ÆÇÄ'    '»ç¶û'    '¸¶À½'    'È¯»ó'; % 85
    '¸¶À½'    'È¯»ó'    '¾ÆÇÄ'    '»ç¶û'; % 86
    '»ç¶û'    'È¯»ó'    '¸¶À½'    '¾ÆÇÄ'; % 87
    'È¯»ó'    '¸¶À½'    '¾ÆÇÄ'    '»ç¶û';
    '¸¶À½'    '»ç¶û'    '¾ÆÇÄ'    'È¯»ó';
    '¾ÆÇÄ'    '¸¶À½'    '»ç¶û'    'È¯»ó';
    '»ç¶û'    '¸¶À½'    'È¯»ó'    '¾ÆÇÄ';
    'È¯»ó'    '¸¶À½'    '»ç¶û'    '¾ÆÇÄ';
    '¸¶À½'    '¾ÆÇÄ'    '»ç¶û'    'È¯»ó';
    'È¯»ó'    '¾ÆÇÄ'    '»ç¶û'    '¸¶À½';
    '»ç¶û'    'È¯»ó'    '¾ÆÇÄ'    '¸¶À½';
    '¾ÆÇÄ'    '¸¶À½'    'È¯»ó'    '»ç¶û';
    '¾ÆÇÄ'    'È¯»ó'    '¸¶À½'    '»ç¶û';
    '¸¶À½'    '¾ÆÇÄ'    'È¯»ó'    '»ç¶û';
    '¾ÆÇÄ'    'È¯»ó'    '»ç¶û'    '¸¶À½';
    'È¯»ó'    '»ç¶û'    '¸¶À½'    '¾ÆÇÄ';
    '¸¶À½'    '¾ÆÇÄ'    '»ç¶û'    'È¯»ó'; 
    '»ç¶û'    '¸¶À½'    '¾ÆÇÄ'    'È¯»ó'}; % 35
seeds_rand = seeds_rand(i,:)