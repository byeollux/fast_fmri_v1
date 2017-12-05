function [fname, start_line, SID, SessID] = subjectinfo_check(savedir, varargin)

% Get subject information, and check if the data file exists?
%
% :Usage:
% ::
%     [fname, start_line, SID] = subjectinfo_check(savedir, varargin)
%
%
% :Inputs:
%
%   **savedir:**
%       The directory where you save the data
%
% :Optional Inputs: 
%
%   **'word':** 
%       Check the data file for fast_fmri_word_generation.m
%
%   **'task':** 
%       Check the data file for fast_fmri_task_main.m
%
%   **'survey':**
%       Check the data file for fast_survey_main.m
%
% ..
%    Copyright (C) 2017  Wani Woo (Cocoan lab)
% ..

%% SETUP: varargin
task = false;
survey = false;
word = false;
resting = false;

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'word'}
                word = true;
            case {'task'}
                task = true;
            case {'survey'}
                survey = true;
            case {'resting'}
                resting = true;
        end
    end
end

%% Get subject ID    
fprintf('\n');
SID = input('Subject ID (number)? ', 's');
if ~(resting + survey)
    SessID = input('Session number? ', 's'); end
    
%% Check if the data file exists
if word
    fname = fullfile(savedir, ['a_worddata_sub' SID '_sess' SessID '.mat']);
elseif task
    fname = fullfile(savedir, ['c_taskdata_sub' SID '_sess' SessID '.mat']);
elseif survey
    fname = fullfile(savedir, ['d_surveydata_sub' SID '.mat']);
elseif resting
    fname = fullfile(savedir, ['e_restingdata_sub' SID '.mat']);
else
    error('Unknown input');
end

%% What to do if the file exists?
if ~exist(savedir, 'dir')
    mkdir(savedir);
    whattodo = 1;
else    
    if exist(fname, 'file')
        str = ['The Subject ' SID ' data file exists. Press a button for the following options'];
        disp(str);
        whattodo = input('1:Save new file, 2:Save the data from where we left off, Ctrl+C:Abort? ');
    else
        whattodo = 1;
    end
    
end
    
%% If we want to start the task from where we left off

if (whattodo == 2 && task) || (whattodo == 2 && word)
    
    error('You need to start from the beginning. Please check the file, and choose 1:Save new file. next time');
    
elseif whattodo == 2 && survey      % is it right? 'survey' include task part. 
    
    temp = load(fname);
    temp_f = fields(temp);
    eval(['temp = temp.' temp_f{1} ';']);
    
    if task
        start_line(1) = numel(temp.audiodata);
        
    elseif survey
        seeds_i = 1;
        target_i = 1;
        for j = 1:4
            if ~isempty(temp.dat{1,j})
                seeds_i = j;
            end
        end
        start_line(1) = seeds_i; % the number of saved seed word

        for i = 1:40
            if ~isempty(temp.dat{i,start_line(1)})
                target_i = i; 
            end   % the final number of saved target word           
        end
        start_line(2) = target_i;
                    
    end
     
else
    start_line = 1;  
end
   
end