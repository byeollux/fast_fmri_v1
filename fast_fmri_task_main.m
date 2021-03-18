function taskdata = fast_fmri_task_main(ts, isi_iti, varargin)

% Run thinking and rating step of Free Association Semantic Task with the fMRI scannin g. 
%
% :Usage:
% ::
%
%    data = fast_survey_main(varargin)
%
% :Inputs:
%
%   **ts:**
%        [W1, W2, isi, iti, iti2]  : isi & iti = 3, 4, 6, 9 secsx
%
% :Optional Inputs: Enter keyword followed by variable with values
%
%   **'test':**
%        This will give you a smaller screen to test your code.
%
%   **'eye', 'eyetrack':**
%        This will turn on the eye tracker, and record eye movement and pupil size. 
%
%   **'biopac':**
%        This will send the trigger to biopac. 
%
%   **'savedir':**
%        You can specify the directory where you save the data.
%        The default is the /data of the current directory.
%
%   **'psychtoolbox':**
%        You can specify the psychtoolbox directory. 
%
%   **'scriptdir':**
%        You can specify the script directory. 
%
% :Examples:
% ::
%
% ts{j} = {{'w1', 'w2'}, [6], [0], [0]} -> no rating
% ts{j} = {{'w1', 'w2'}, [6], [9], [0]} -> rating
% ts{j} = {{'w1', 'w2'}, [6], [0], [4]} -> concentration question
% 
% ..
%    Copyright (C) 2017 COCOAN lab
% ..
%
%    If you have any questions, please email to: 
%          Byeol Kim (roadndream@naver.com) 
%
%% default setting
testmode = false;
USE_EYELINK = false;
USE_BIOPAC = false;
savedir = fullfile(pwd, 'data');

addpath(genpath(pwd));
%% parsing varargin
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'test', 'testmode'}
                testmode = true;
            case {'savedir'}
                savedir = varargin{i+1};
            case {'eyelink', 'eye', 'eyetrack'}
                USE_EYELINK = true;
            case {'biopac'}
                USE_BIOPAC = true;
                channel_n = 1;
                biopac_channel = 0;
                ljHandle = BIOPAC_setup(channel_n); % BIOPAC SETUP
        end
    end
end

%% SETUP: global
global theWindow W H; % window property
global white red orange blue bgcolor; % color
global fontsize window_rect rT cqT ; % rating scale

%% SETUP: Screen

bgcolor = 100;

if testmode
    window_rect = [0 0 1280 800]; % in the test mode, use a little smaller screen
else
    % these 5 lines are from CAPS. In case of fMRI+ThinkPad+full
    % screen, these are nessecary and different from Wani's version.
    screens = Screen('Screens');
    window_num = screens(end);
    Screen('Preference', 'SkipSyncTests', 1);
    window_info = Screen('Resolution', window_num);
    window_rect = [0 0 window_info.width window_info.height]; %0 0 1920 1080
end

W = window_rect(3); %width of screen
H = window_rect(4); %height of screen
textH = H/2.3;

% font = 'NanumGothic';
fontsize = 30;

white = 255;
red = [189 0 38];
blue = [0 85 169];
orange = [255 164 0];

wordT = 15;     % duration for showing target words
rT = 10;         % duration for rating
cqT = 8;        % duration for question of concentration

%% SETUP: DATA and Subject INFO

    [~, ~, SID, SessID] = subjectinfo_check(savedir, 'task'); % subfunction
    
    % add some task information
    taskdata.version = 'FAST_fmri_task_v1_02-19-2018';
    taskdata.github = 'https://github.com/byeolstellakim/fast_fmri_v1';
    taskdata.subject = SID;
    taskdata.session = SessID;
    taskdata.wordfile = fullfile(savedir, ['a_worddata_sub' SID '_sess' SessID '.mat']);
    taskdata.responsefile = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);
    taskdata.taskfile = fullfile(savedir, ['c_taskdata_sub' SID '_sess' SessID '.mat']);
    taskdata.surveyfile = fullfile(savedir, ['d_surveydata_sub' SID '.mat']);
    taskdata.restingfile = fullfile(savedir, ['e_restingdata_sub' SID '.mat']);
    taskdata.exp_starttime = datestr(clock, 0); % date-time: timestamp
    taskdata.isiiti = isi_iti;
    
    % initial save of trial sequence and data
    save(taskdata.taskfile, 'taskdata');
    
    %% START: Screen
    theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect); % start the screen
    Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
%     Screen('TextFont', theWindow, font);
    Screen('TextSize', theWindow, fontsize);
    HideCursor;
    
    %% SETUP: Eyelink
    
    % need to be revised when the eyelink is here.
    if USE_EYELINK
        edf_filename = ['T_' SID '_' SessID]; % name should be equal or less than 8
        edfFile = sprintf('%s.EDF', edf_filename);
        eyelink_main(edfFile, 'Init');
        
        status = Eyelink('Initialize');
        if status
            error('Eyelink is not communicating with PC. Its okay baby.');
        end
        Eyelink('Command', 'set_idle_mode');
        waitsec_fromstarttime(GetSecs, .5);
    end


%% TASK START

try
    %% PROMPT SETUP:
    practice_prompt = double('연습을 해보겠습니다.\n여러 개의 감정 단어들이 나타나면 10초 안에\n트랙볼로 커서를 움직여 아무 단어나 클릭하시면 됩니다.\n\n준비되셨으면 버튼을 눌러주세요');
    exp_start_prompt{1} = double('이제부터 여러분이 방금 말씀하셨던 단어들을 순서대로 보게 될 것입니다.');
    exp_start_prompt{2} = double('각 단어들을 15초 동안 보여드릴텐데 그 시간동안 그 단어들이');
    exp_start_prompt{3} = double('여러분에게 어떤 의미로 다가오는지 자연스럽게 생각해보시기 바랍니다.');
    exp_start_prompt{4} = double('\n실험자는 모든 것이 잘 준비되었는지 체크해주세요 (Biopac, Eyelink, 등등).\n\n모두 준비되었으면, 스페이스바를 눌러주세요.');
    ready_prompt = double('참가자가 준비되었으면, 이미징을 시작합니다 (s).');
    run_end_prompt = double('잘하셨습니다. 잠시 대기해 주세요.');
    
    %% PRACTICE RATING: Test trackball, Practice emotion rating
    if str2double(SessID) ==1
        % viewing the practice prompt until click.
        while (1)
            [~, ~, button] = GetMouse(theWindow);
            [~,~,keyCode] = KbCheck;
            
            if button(1)
                break
            elseif keyCode(KbName('q'))==1
                abort_man;
            end
            Screen(theWindow,'FillRect',bgcolor, window_rect);
            DrawFormattedText(theWindow, practice_prompt, 'center', 'center', white, [], [], [], 1.5);
            Screen('Flip', theWindow);
        end
        WaitSecs(.1)
        emotion_rating(GetSecs); % sub-function: 10s
        
        WaitSecs(1);
    end
        
    %% DISPLAY EXP START MESSAGE
    while (1)
        [~,~,keyCode] = KbCheck;
        
        if keyCode(KbName('space'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_man;
        end
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        for i = 1:numel(exp_start_prompt)
            DrawFormattedText(theWindow, exp_start_prompt{i},'center', textH-40*(2-i), white);
        end
        Screen('Flip', theWindow);
    end
    
    %% WAITING FOR INPUT FROM THE SCANNER
    while (1)
        [~,~,keyCode] = KbCheck;
        
        if keyCode(KbName('s'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_experiment('manual');
        end
        
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        DrawFormattedText(theWindow, ready_prompt,'center', textH, white);
        Screen('Flip', theWindow);
    end
    
    %% FOR DISDAQ 10 SECONDS
    
    % gap between 's' key push and the first stimuli (disdaqs: data.disdaq_sec)
    % 4 seconds: "시작합니다..."
    taskdata.runscan_starttime = GetSecs; % run start timestamp
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double('시작합니다...'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(taskdata.runscan_starttime, 4);
    
    % Blank
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
        
    %% EYELINK AND BIOPAC START
    
    if USE_EYELINK
        Eyelink('StartRecording');
        taskdata.eyetracker_starttime = GetSecs; % eyelink timestamp
        Eyelink('Message','Task Run start');
    end
        
    if USE_BIOPAC
        taskdata.biopac_starttime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(taskdata.biopac_starttime, 0.6);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    % 10 seconds from the runstart
    waitsec_fromstarttime(taskdata.runscan_starttime, 10);
    
    
    %% MAIN TASK 1. SHOW 2 WORDS, WORD PROMPT
    for ts_i = 1:numel(ts)   % repeat for 40 trials
        taskdata.dat{ts_i}.trial_starttime = GetSecs; % trial start timestamp
        display_target_word(ts{ts_i}{1}); % sub-function, display two generated words
        if USE_EYELINK
            Eyelink('Message','Task Words present');
        end
        waitsec_fromstarttime(taskdata.dat{ts_i}.trial_starttime, wordT); % for 15s
         
        % Blank for ISI
        taskdata.dat{ts_i}.isi_starttime = GetSecs;  % ISI start timestamp
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('Flip', theWindow);
        if USE_EYELINK
            Eyelink('Message','ISI blank');
        end
        waitsec_fromstarttime(taskdata.dat{ts_i}.trial_starttime, wordT+ts{ts_i}{2});
        
        
        % Emotion Rating
        if ts{ts_i}{3} ~= 0 && ts_i ~= 20  % if 3rd column of ts is not 0, do rating for 10s
            if USE_EYELINK
                Eyelink('Message','Rating present');
            end
            taskdata.dat{ts_i}.emotion_starttime = GetSecs;  % rating start timestamp
            [taskdata.dat{ts_i}.emotion_word, taskdata.dat{ts_i}.emotion_time, ...
             taskdata.dat{ts_i}.emotion_trajectory] = emotion_rating(taskdata.dat{ts_i}.emotion_starttime); % sub-function
                        
            % Blank for ITI
            if USE_EYELINK
                Eyelink('Message','ITI blank');
            end
            taskdata.dat{ts_i}.iti_starttime = GetSecs;    % ITI start timestamp
            Screen(theWindow,'FillRect',bgcolor, window_rect);
            Screen('Flip', theWindow);
            waitsec_fromstarttime(taskdata.dat{ts_i}.trial_starttime, wordT+ts{ts_i}{2}+rT+ts{ts_i}{3});
            
            
        % Concentration Qustion
        elseif ts_i == 20   % 20th trial, ask concentration for 8(cqT)+3s
            if USE_EYELINK
                Eyelink('Message','Concentration present');
            end
            taskdata.dat{ts_i}.concent_starttime = GetSecs;  % rating start timestamp
            [taskdata.dat{ts_i}.concentration, taskdata.dat{ts_i}.concent_time, ...
                taskdata.dat{ts_i}.concent_trajectory] = concent_rating(taskdata.dat{ts_i}.concent_starttime); % sub-function
            
            % Blank for ITI
            if USE_EYELINK
                Eyelink('Message','ITI blank');
            end
            taskdata.dat{ts_i}.iti_starttime = GetSecs;    % ITI start timestamp
            Screen(theWindow,'FillRect',bgcolor, window_rect);
            Screen('Flip', theWindow);
            
            waitsec_fromstarttime(taskdata.dat{ts_i}.trial_starttime, wordT+ts{ts_i}{2}+cqT+ts{ts_i}{3});
            
            
        % The last question    
        elseif ts_i == 40
            if USE_EYELINK
                Eyelink('Message','Final Rating');
            end
            taskdata.dat{ts_i}.emotion_starttime = GetSecs;  % rating start timestamp
            [taskdata.dat{ts_i}.emotion_word, taskdata.dat{ts_i}.emotion_time, ...
             taskdata.dat{ts_i}.emotion_trajectory] = emotion_rating(taskdata.dat{ts_i}.emotion_starttime); % sub-function

            if USE_EYELINK
                Eyelink('Message','Final Concentration');
            end
            taskdata.dat{ts_i}.concent_starttime = GetSecs;  % rating start timestamp
            [taskdata.dat{ts_i}.concentration, taskdata.dat{ts_i}.concent_time, ...
                taskdata.dat{ts_i}.concent_trajectory] = concent_rating(taskdata.dat{ts_i}.concent_starttime); % sub-function

        end
              
        % save data every even trial
        if mod(ts_i, 2) == 0 
            save(taskdata.taskfile, 'taskdata', '-append'); % 'append' overwrite with adding new columns to 'data'
        end
        
    end
    
    %% RUN END MESSAGE
    Screen('TextSize', theWindow, fontsize);    
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    DrawFormattedText(theWindow, run_end_prompt, 'center', 'center', white, [], [], [], 1.5);
    Screen('Flip', theWindow);
    
    if USE_EYELINK
        Eyelink('Message','Task Run End');
        eyelink_main(edfFile, 'Shutdown');
    end
    if USE_BIOPAC
        taskdata.biopac_endtime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(taskdata.biopac_endtime, 0.1);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    save(taskdata.taskfile, 'taskdata', '-append');
    
    WaitSecs(2);

    ShowCursor; %unhide mouse
    Screen('CloseAll'); %relinquish screen control 
    
catch err
    % ERROR 
    disp(err);
    for i = 1:numel(err.stack)
        disp(err.stack(i));
    end
    abort_experiment('error');  
end

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


%% ========================== SUB-FUNCTIONS ===============================

function display_target_word(words)

global W H white theWindow window_rect bgcolor fontsize

fontsz = [fontsize*45/30 fontsize*65/30];
% Calcurate the W & H of two generated words
Screen('TextSize', theWindow, fontsz(1));
[response_W(1), response_H(1)] = Screen(theWindow, 'DrawText', double(words{1}), 0, 0);

Screen('TextSize', theWindow, fontsz(2));
[response_W(2), response_H(2)] = Screen(theWindow, 'DrawText', double(words{2}), 0, 0);

interval = 150;  % between two words
% coordinates of the words 
x(1) = W/2 - interval - response_W(1) - response_W(2)/2;
x(2) = W/2 - response_W(2)/2;

y(1) = H/2 - response_H(1);
y(2) = H/2 - response_H(2);

Screen(theWindow,'FillRect',bgcolor, window_rect);

Screen('TextSize', theWindow, fontsz(1)); % previous word, fontsize = 45
DrawFormattedText(theWindow, double(words{1}), x(1), y(1), white-80, [], [], [], 1.5);

Screen('TextSize', theWindow, fontsz(2)); % present word, fontsize = 65
DrawFormattedText(theWindow, double(words{2}), x(2), y(2), white, [], [], [], 1.5);

Screen('Flip', theWindow);

end

function [emotion_word, trajectory_time, trajectory] = emotion_rating(starttime)

global W H orange bgcolor window_rect theWindow red rT

rng('shuffle');        % it prevents pseudo random number
rand_z = randperm(14); % random seed
[choice, xy_rect] = display_emotion_words(rand_z);

SetMouse(880, 500);
% SetMouse(W/2, H/2);

trajectory = [];
trajectory_time = [];

j = 0;

while(1)
    j = j + 1;
    [x, y, button] = GetMouse(theWindow);
    mx = x*1.1;
    my = y*1.1;
    
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    display_emotion_words(rand_z);
    Screen('DrawDots', theWindow, [mx my], 10, orange, [0, 0], 1); % draw orange dot on the cursor
    Screen('Flip', theWindow);
    
    trajectory(j,:) = [mx my];                  % trajectory of location of cursor
    trajectory_time(j) = GetSecs - starttime; % trajectory of time
    
    if trajectory_time(end) >= rT  % maximum time of rating is 8s
        button(1) = true;
    end
    
    if button(1)  % After click, the color of cursor dot changes.
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        display_emotion_words(rand_z);
        Screen('DrawDots', theWindow, [mx;my], 10, red, [0 0], 1);
        Screen('Flip', theWindow);
        
        % which word based on x y from mouse click
        choice_idx = mx > xy_rect(:,1) & mx < xy_rect(:,3) & my > xy_rect(:,2) & my < xy_rect(:,4);
        if any(choice_idx)
            emotion_word = choice{choice_idx};
        else
            emotion_word = '';
        end
        
        WaitSecs(0.3);   
        
        break;
    end
end

end

function [choice, xy_rect] = display_emotion_words(z)

global W H white theWindow window_rect bgcolor square fontsize

square = [0 0 140 80];  % size of square of word
r=350;
t=360/28;
theta=[t, t*3, t*5, t*7, t*9, t*11, t*13, t*15, t*17, t*19, t*21, t*23, t*25, t*27];
xy=[W/2+r*cosd(theta(1)) H/2-r*sind(theta(1)); W/2+r*cosd(theta(2)) H/2-r*sind(theta(2)); ...
    W/2+r*cosd(theta(3)) H/2-r*sind(theta(3)); W/2+r*cosd(theta(4)) H/2-r*sind(theta(4));...
    W/2+r*cosd(theta(5)) H/2-r*sind(theta(5)); W/2+r*cosd(theta(6)) H/2-r*sind(theta(6));...
    W/2+r*cosd(theta(7)) H/2-r*sind(theta(7)); W/2+r*cosd(theta(8)) H/2-r*sind(theta(8));...
    W/2+r*cosd(theta(9)) H/2-r*sind(theta(9)); W/2+r*cosd(theta(10)) H/2-r*sind(theta(10));...
    W/2+r*cosd(theta(11)) H/2-r*sind(theta(11)); W/2+r*cosd(theta(12)) H/2-r*sind(theta(12));...
    W/2+r*cosd(theta(13)) H/2-r*sind(theta(13)); W/2+r*cosd(theta(14)) H/2-r*sind(theta(14))];

xy_word = [xy(:,1)-square(3)/2, xy(:,2)-square(4)/2-15, xy(:,1)+square(3)/2, xy(:,2)+square(4)/2];
xy_rect = [xy(:,1)-square(3)/2, xy(:,2)-square(4)/2, xy(:,1)+square(3)/2, xy(:,2)+square(4)/2];

colors = 200;

%% words

choice = {'기쁨', '괴로움', '희망', '두려움', '행복', '실망', '자부심', '부끄러움', '후회', '슬픔', '분노', '사랑', '미움', '없음'};
choice = choice(z);

%%
Screen(theWindow,'FillRect',bgcolor, window_rect);
Screen('TextSize', theWindow, fontsize);
% Rectangle
for i = 1:numel(theta)
    Screen('FrameRect', theWindow, colors, CenterRectOnPoint(square,xy(i,1),xy(i,2)),3);
end
% Choice letter
for i = 1:numel(choice)
    DrawFormattedText(theWindow, double(choice{i}), 'center', 'center', white, [],[],[],[],[],xy_word(i,:));
end

end

function [concentration, trajectory_time, trajectory] = concent_rating(starttime)

global W H orange bgcolor window_rect theWindow red fontsize white cqT
intro_prompt1 = double('지금, 나타나는 단어들에 대해 얼마나 주의를 잘 기울이고 계신가요?');
intro_prompt2 = double('8초 안에 트랙볼을 움직여서 집중하고 있는 정도를 클릭해주세요.');
title={'전혀 기울이지 않음','보통', '매우 집중하고 있음'};

SetMouse(W/2, H/2);

trajectory = [];
trajectory_time = [];
xy = [W/3 W*2/3 W/3 W/3 W*2/3 W*2/3;
      H/2 H/2 H/2-7 H/2+7 H/2-7 H/2+7];

j = 0;

while(1)
    j = j + 1;
    [mx, my, button] = GetMouse(theWindow);
    
    x = mx;
    y = H/2;
    if x < W/3, x = W/3;
    elseif x > W*2/3, x = W*2/3;
    end
    
    Screen('TextSize', theWindow, fontsize);
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('DrawLines',theWindow, xy, 5, 255);
    DrawFormattedText(theWindow, intro_prompt1,'center', H/4, white);
    DrawFormattedText(theWindow, intro_prompt2,'center', H/4+40, white);
    % Draw scale letter
    DrawFormattedText(theWindow, double(title{1}),'center', 'center', white, ...
                [],[],[],[],[], [xy(1,1)-70, xy(2,1), xy(1,1)+20, xy(2,1)+60]);
    DrawFormattedText(theWindow, double(title{2}),'center', 'center', white, ...
                [],[],[],[],[], [W/2-15, xy(2,1), W/2+20, xy(2,1)+60]);
    DrawFormattedText(theWindow, double(title{3}),'center', 'center', white, ...
                [],[],[],[],[], [xy(1,2)+45, xy(2,1), xy(1,2)+20, xy(2,1)+60]);

    Screen('DrawDots', theWindow, [x y], 10, orange, [0, 0], 1); % draw orange dot on the cursor
    Screen('Flip', theWindow);
        
    trajectory(j,:) = [(x-W/2)/(W/3)];    % trajectory of location of cursor
    trajectory_time(j) = GetSecs - starttime; % trajectory of time

    if trajectory_time(end) >= cqT  % maximum time of rating is 5s
        button(1) = true;
    end
    
    if button(1)  % After click, the color of cursor dot changes.
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('DrawLines',theWindow, xy, 5, 255);
        DrawFormattedText(theWindow, intro_prompt1,'center', H/4, white);
        DrawFormattedText(theWindow, intro_prompt2,'center', H/4+40, white);
        % Draw scale letter
        DrawFormattedText(theWindow, double(title{1}),'center', 'center', white, ...
            [],[],[],[],[], [xy(1,1)-70, xy(2,1), xy(1,1)+20, xy(2,1)+60]);
        DrawFormattedText(theWindow, double(title{2}),'center', 'center', white, ...
            [],[],[],[],[], [W/2-15, xy(2,1), W/2+20, xy(2,1)+60]);
        DrawFormattedText(theWindow, double(title{3}),'center', 'center', white, ...
            [],[],[],[],[], [xy(1,2)+45, xy(2,1), xy(1,2)+20, xy(2,1)+60]);
        Screen('DrawDots', theWindow, [x;y], 10, red, [0 0], 1);
        Screen('Flip', theWindow);
        
        concentration = (x-W/3)/(W/3);  % 0~1
        
        WaitSecs(0.3);   
        break;
    end    
end
end