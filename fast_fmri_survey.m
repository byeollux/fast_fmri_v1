function survey = fast_fmri_survey(words, varargin)
%
%   out.dat{target_i,seeds_i}{barsize(5,j)}.tracjectory
%   out.dat{target_i,seeds_i}{barsize(5,j)}.time
%   out.dat{target_i,seeds_i}{barsize(5,j)}.rating      
%                               for bodymap, rating_red & rating_blue
%   out.dat{target_i,seeds_i}{barsize(5,j)}.RT
%
%       for example, 
%   out.dat{target_i,seeds_i}{1}.tracjectory = 'Valence'
%   out.dat{target_i,seeds_i}{2}.tracjectory = 'Self-relevance'
%   out.dat{target_i,seeds_i}{3}.tracjectory = 'Time'
%   out.dat{target_i,seeds_i}{4}.tracjectory = 'Vividness'
%   out.dat{target_i,seeds_i}{5}.tracjectory = 'SafetyThreat'
%   out.dat{target_i,seeds_i}{6}.tracjectory = 'Bodymap'
%
%
%% default setting
testmode = false;
practice_mode = false;
savedir = fullfile(pwd, 'data');
psychtoolboxdir = '/Users/byeoletoile/Documents/MATLAB/Psychtoolbox';
scriptdir = pwd;

practice_repeat= 4;

%% PARSING OUT OPTIONAL INPUT
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'practice'}
                practice_mode = true;
            case {'test', 'testmode'}
                testmode = true;
            case {'savedir'}
                savedir = varargin{i+1};
        end
    end
end

%% SETUP: global
global theWindow W H; % window property
global white red orange blue bgcolor ; % color
global fontsize window_rect lb tb bodymap recsize barsize rec; % rating scale

%% SETUP: Screen

bgcolor = 100;

if testmode
    window_rect = [0 0 1280 800]; % in the test mode, use a little smaller screen
else
    screensize = get(groot, 'Screensize');
    window_rect = [0 0 screensize(3) screensize(4)];
end


W = window_rect(3); %width of screen
H = window_rect(4); %height of screen
textH = H/2.3;

font = 'NanumBarunGothic';
fontsize = 30;

white = 255;
red = [189 0 38];
blue = [0 85 169];
orange = [255 164 0];

lb=W*8/128;     %110        when W=1280
tb=H*18/80;     %180

recsize=[W*450/1280 H*175/800]; 
barsizeO=[W*340/1280, W*180/1280, W*340/1280, W*180/1280, W*340/1280, 0;
    10, 10, 10, 10, 10, 0; 10, 0, 10, 0, 10, 0;
    10, 10, 10, 10, 10, 0; 1, 2, 3, 4, 5, 0];
rec=[lb,tb; lb+recsize(1),tb; lb,tb+recsize(2); lb+recsize(1),tb+recsize(2);
    lb,tb+2*recsize(2); lb+recsize(1),tb+2*recsize(2)]; %6개 사각형의 왼쪽 위 꼭짓점의 좌표

bodymap = imread('imgs/bodymap_bgcolor.jpg');  
bodymap = bodymap(:,:,1);
[body_y, body_x] = find(bodymap(:,:,1) == 255);

bodymap([1:10 791:800], :) = [];
bodymap(:, [1:10 1271:1280]) = []; % make the picture smaller


%% SETUP: DATA and Subject INFO

if ~practice_mode % if not practice mode, save the data
    
    [fname, start_line, SID] = subjectinfo_check(savedir, 'survey'); % subfunction
    if exist(fname, 'file'), load(fname, 'survey'); end
    
    % add some task information
    survey.version = 'FAST_fmri_task_v1_11-08-2017';
    survey.github = 'https://github.com/ByeolEtoileKim/fast_fmri_v1';
    survey.subject = SID;
    survey.wordfile = fullfile(savedir, ['a_worddata_sub' SID '_sessnumber.mat']);
    survey.responsefile = fullfile(savedir, ['b_responsedata_sub' SID '_sessnumber.mat']);
    survey.taskfile = fullfile(savedir, ['c_taskdata_sub' SID '_sessnumber.mat']);
    survey.surveyfile = fullfile(savedir, ['d_surveydata_sub' SID '.mat']);
    survey.restingfile = fullfile(savedir, ['e_restingdata_sub' SID '.mat']);
    survey.exp_starttime = datestr(clock, 0); % date-time: timestamp
    survey.dat_descript = {'nth of cell:Questions'; '1:Valence'; '2:Self-relevance'; '3:Time'; '4:Vividness'; '5:SafetyThreat'; '6:Bodymap'};
    survey.dat_body_xy = [body_x body_y];
    survey.dat = cell(size(words,1)-1, size(words,2));
    
    % initial save of trial sequence and data
    save(survey.surveyfile, 'words', 'survey');
    
end


%% Survey start: =========================================================

    %% START: Screen
	theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
    Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
    Screen('TextFont', theWindow, font); 
    Screen('TextSize', theWindow, fontsize);
    HideCursor;
    
    %% PROMPT SETUP:
    ready_prompt{1} = double('지금부터 스캐너에서 말한 각 단어를 바로 직전에 말한 단어와');
    ready_prompt{2} = double('이어지는 맥락을 고려하여 각 질문에 솔직하게 응답해주세요.');
    ready_prompt{3} = double('여기서 맥락이란 일반적인 단어 사이의 관계를 의미하는 것이 아니라,');
    ready_prompt{4} = double('본인이 그 단어를 떠올렸을 당시에 느꼈던 개인적인 감정 혹은 생각을 의미합니다.');
    ready_prompt{5} = double('설문은 총 6개의 세트로 이루어져 있으며 세트가 끝날 때마다 휴식을 취하셔도 좋습니다.');
    ready_prompt{6} = double('약 2시간 정도 예상되는 설문이므로 마지막까지 집중해서 응답해주시기를 바랍니다.');
    ready_prompt{7} = double('\n시작하려면 스페이스를 눌러주세요.');

    practice_end_prompt = double('잘하셨습니다. 질문이 있으신가요?');
    run_end_prompt = double('잘하셨습니다. 잠시 휴식을 가지셔도 됩니다.\n다음 세트를 시작할 준비가 되면 스페이스를 눌러주세요.');

    exp_end_prompt = double('설문을 모두 마치셨습니다. 감사합니다!');

    %% PRACTICE 
    
    % viewing the practice prompt until click. 
    if practice_mode
        pw = {'음악';'크리스마스';'고양이';'노랑';'레몬'};
        seeds_i = 1;
        while (1)
            [~,~,keyCode] = KbCheck;
            if keyCode(KbName('space'))==1
                break;
            elseif keyCode(KbName('q'))==1
                abort_experiment('manual');
            end
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('TextSize', theWindow, fontsize);
            for i = 1:numel(ready_prompt)
                DrawFormattedText(theWindow, ready_prompt{i},'center', H*5/12-40*(2-i), white);
            end
            Screen('Flip', theWindow);
        end
        
        for target_i = 1:practice_repeat % loop through the response words (5)
            z = randperm(6);
            barsize = barsizeO(:,z);
            for j=1:numel(z)
                if ~barsize(5,j) == 0
                    if mod(barsize(5,j),2) ==0
                        SetMouse(rec(j,1)+(recsize(1)-barsize(1,j))/2, rec(j,2)+recsize(2)/2);
                    else SetMouse(rec(j,1)+recsize(1)/2, rec(j,2)+recsize(2)/2);
                    end
                    while(1)
                        % Track Mouse coordinate
                        [mx, my, button] = GetMouse(theWindow);
                        
                        x = mx;
                        y = rec(j,2)+recsize(2)/2;
                        if x < rec(j,1)+(recsize(1)-barsize(1,j))/2, x = rec(j,1)+(recsize(1)-barsize(1,j))/2;
                        elseif x > rec(j,1)+(recsize(1)+barsize(1,j))/2, x = rec(j,1)+(recsize(1)+barsize(1,j))/2;
                        end
                        display_survey(z, seeds_i, target_i, pw,'practice1');
                        Screen('DrawDots', theWindow, [x;y], 9, orange, [0 0], 1);
                        Screen('Flip', theWindow);
                        
                        if button(1)
                            display_survey(z, seeds_i, target_i, pw,'practice1');
                            Screen('DrawDots', theWindow, [x,y], 9, red, [0 0], 1);
                            Screen('Flip', theWindow);
                            WaitSecs(.3);
                            break;
                        end
                    end
                end
            end
            WaitSecs(.1)
            
            % bodymap
            SetMouse(W*8.6/10, H/2); % set mouse at the center of the body
            
            zc = randperm(2);
            if zc(1)==1
                 color = red;  color_code = 1;
            else color = blue; color_code = 2;   end
            
            while(1)
                display_survey(z, seeds_i, target_i, pw,'practice2');
                
                % Track Mouse coordinate
                [x, y, button] = GetMouse(theWindow);
                [~,~,keyCode] = KbCheck;
                
                if keyCode(KbName('r'))==1
                    color = red;
                    color_code = 1;
                    keyCode(KbName('r')) = 0;
                elseif keyCode(KbName('b'))==1
                    color = blue;
                    color_code = 2;
                    keyCode(KbName('b')) = 0;
                end
                
                Screen('DrawDots', theWindow, [x;y], 5, color, [0 0], 1);
                Screen('Flip', theWindow);
                if keyCode(KbName('a'))==1
                    Screen(theWindow, 'FillRect', bgcolor, window_rect);
                    Screen('Flip', theWindow);
                    WaitSecs(.5);
                    break;
                end
            end
        end
        
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('TextSize', theWindow, fontsize);
        DrawFormattedText(theWindow, practice_end_prompt, 'center', 'center', white, [], [], [], 1.5);
        Screen('Flip', theWindow);
        KbWait;
        Screen('CloseAll');
    end
        
    
    %% Main function: show 2 words
    for seeds_i = start_line(1):numel(words(1,:)) % loop through the seed words
        % Set restart point in case of overwrite.
        % Restart target word from 'start_line(2)'
        % just for stopped seed words.
        if numel(start_line) == 2 && seeds_i == start_line(1)
            start_target = start_line(2); 
        else
            start_target = 1;
        end
        
        % Get ready message: waiting for a space bar
        while (1)
            [~,~,keyCode] = KbCheck;
            if keyCode(KbName('space'))==1
                break;
            elseif keyCode(KbName('q'))==1
                abort_experiment('manual');
            end
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            for i = 1:numel(ready_prompt)
                DrawFormattedText(theWindow, ready_prompt{i},'center', H*5/12-40*(2-i), white);
            end
            Screen('Flip', theWindow);
        end
        
        
        for target_i = start_target:numel(words(:,1))-1 % loop through the response words (40)
  
            %% FIRST question : Self-relevance, Valence, Time, Vividness, Safety/Threat 
            z= randperm(6);
            barsize = barsizeO(:,z);
                                   
            for j=1:numel(barsize(5,:))
                if ~barsize(5,j) == 0 % if barsize(5,j) = 0, skip the scale
                    % if Self, Vivid question, set curson on the left.
                    % the other, set curson on the center.                   
                    if mod(barsize(5,j),2) == 0  
                        SetMouse(rec(j,1)+(recsize(1)-barsize(1,j))/2, rec(j,2)+recsize(2)/2);
                    else SetMouse(rec(j,1)+recsize(1)/2, rec(j,2)+recsize(2)/2);
                    end
                    
                    rec_i = 0;
                    survey.dat{target_i, seeds_i}{barsize(5,j)}.trajectory = [];
                    survey.dat{target_i, seeds_i}{barsize(5,j)}.time = [];
                    
                    starttime = GetSecs; % Each question start time
                    
                    while(1)
                        % Track Mouse coordinate
                        [mx, my, button] = GetMouse(theWindow);
                        
                        x = mx;  % x of a color dot
                        y = rec(j,2)+recsize(2)/2;
                        if x < rec(j,1)+(recsize(1)-barsize(1,j))/2, x = rec(j,1)+(recsize(1)-barsize(1,j))/2;
                        elseif x > rec(j,1)+(recsize(1)+barsize(1,j))/2, x = rec(j,1)+(recsize(1)+barsize(1,j))/2;
                        end
                        
                        % display scales and cursor
                        display_survey(z, seeds_i, target_i, words,'whole');
                        Screen('DrawDots', theWindow, [x;y], 9, orange, [0 0], 1);
                        Screen('Flip', theWindow);
                        
                        % Get trajectory
                        rec_i = rec_i+1; % the number of recordings
                        survey.dat{target_i, seeds_i}{barsize(5,j)}.trajectory(rec_i,1) = rating(x, j);
                        survey.dat{target_i, seeds_i}{barsize(5,j)}.time(rec_i,1) = GetSecs - starttime;
                        
                        if button(1)
                            survey.dat{target_i, seeds_i}{barsize(5,j)}.rating = rating(x, j);
                            survey.dat{target_i, seeds_i}{barsize(5,j)}.RT = ...
                                survey.dat{target_i, seeds_i}{barsize(5,j)}.time(end) - ...
                                survey.dat{target_i, seeds_i}{barsize(5,j)}.time(1);
                        
                            display_survey(z, seeds_i, target_i, words,'whole');
                            Screen('DrawDots', theWindow, [x,y], 9, red, [0 0], 1);
                            Screen('Flip', theWindow);
                            
                            WaitSecs(.3);
                            break;
                        end
                    end
                end
                
                % save 5 questions data every trial (one word pair)
                save(survey.surveyfile, 'survey', '-append');
            end
            
            WaitSecs(.3);
            %% SECOND question: body map
    
            SetMouse(W*8.5/10, H/2); % set mouse at the center of the body
            
            rec_i = 0;
            survey.dat{target_i, seeds_i}{6}.trajectory = [];
            survey.dat{target_i, seeds_i}{6}.time = [];
            survey.dat{target_i, seeds_i}{6}.rating_red = [];
            survey.dat{target_i, seeds_i}{6}.rating_blue = [];   
            
            starttime = GetSecs; % bodymap start time

            % default color is randomized
            zc = randperm(2);
            if zc(1)==1
                 color = red;  color_code = 1;
            else color = blue; color_code = 2;   end
            
            while(1)
                % draw scale
                display_survey(z, seeds_i, target_i, words,'whole');
                
                % Track Mouse coordinate
                [x, y, button] = GetMouse(theWindow);
                [~,~,keyCode] = KbCheck;
                
                if keyCode(KbName('r'))==1
                    color = red;
                    color_code = 1;
                    keyCode(KbName('r')) = 0;
                elseif keyCode(KbName('b'))==1
                    color = blue;
                    color_code = 2;
                    keyCode(KbName('b')) = 0;
                end
                
                % Get trajectory
                rec_i = rec_i+1; % the number of recordings
                
                survey.dat{target_i, seeds_i}{6}.trajectory(rec_i,:) = [x y color_code button(1)];
                survey.dat{target_i, seeds_i}{6}.time(rec_i,1) = GetSecs - starttime;
                
                % current location
                Screen('DrawDots', theWindow, [x;y], 6, color, [0 0], 1);
                
                % color the previous clicked regions
                if ~isempty(survey.dat{target_i, seeds_i}{6}.rating_red)
                    Screen('DrawDots', theWindow, survey.dat{target_i, seeds_i}{6}.rating_red', 6, red, [0 0], 1);
                end               
                if ~isempty(survey.dat{target_i, seeds_i}{6}.rating_blue)
                    Screen('DrawDots', theWindow, survey.dat{target_i, seeds_i}{6}.rating_blue', 6, blue, [0 0], 1);
                end                
                Screen('Flip', theWindow);
                
                if button(1) && color_code == 1
                    survey.dat{target_i, seeds_i}{6}.rating_red = [survey.dat{target_i, seeds_i}{6}.rating_red; [x y]];
                elseif button(1) && color_code == 2
                    survey.dat{target_i, seeds_i}{6}.rating_blue = [survey.dat{target_i, seeds_i}{6}.rating_blue; [x y]];
                end
                
                if keyCode(KbName('a'))==1
                    survey.dat{target_i, seeds_i}{6}.RT = survey.dat{target_i, seeds_i}{6}.time(end) - survey.dat{target_i, seeds_i}{6}.time(1);
                    Screen(theWindow, 'FillRect', bgcolor, window_rect);
                    Screen('Flip', theWindow);
                    WaitSecs(.5);
                    break;
                end
            end
            
            % save data every trial (one word pair)
            save(survey.surveyfile, 'survey', '-append');
           
        end

        %% Run (1 seed word) End
        save(survey.surveyfile, 'survey', '-append')
        
        if seeds_i < numel(words(1,:))
            while (1)
                [~,~,keyCode] = KbCheck;
                if keyCode(KbName('space'))==1
                    break;
                end
                Screen(theWindow, 'FillRect', bgcolor, window_rect);
                DrawFormattedText(theWindow, run_end_prompt, 'center', textH, white);
                Screen('Flip', theWindow);
            end
        end
        
        WaitSecs(1.0);

    end  % end of all seed words

    %% Experiment end message
    
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, exp_end_prompt, 'center', textH, white);
    Screen('Flip', theWindow);
    WaitSecs(2);
    
    ShowCursor; %unhide mouse
    Screen('CloseAll'); %relinquish screen control
end


%% == SUBFUNCTIONS ==============================================


function abort_experiment(varargin)

% ABORT the experiment
%
% abort_experiment(varargin)

str = 'Experiment aborted.';

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'error'}
                str = 'Experiment aborted by error.';
            case {'manual'}
                str = 'Experiment aborted by the experimenter.';
        end
    end
end


ShowCursor; %unhide mouse
Screen('CloseAll'); %relinquish screen control
disp(str); %present this text in command window

end

function rx = rating(x, j)

global barsize recsize rec;
% rx start from 0
if mod(barsize(5,j),2) == 0     % Self, Vividness: 0<=rx<=1
    rx = x-(rec(j,1)+(recsize(1)-barsize(1,j))/2)/barsize(1,j);
else                            % Valence, Time, Safety/Threat: -1<=rx<=1
    rx = x-(rec(j,1)+(recsize(1)-barsize(1,j))/2)/(2*barsize(1,j))-1;
end

end
