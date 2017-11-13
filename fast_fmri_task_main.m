function data = fast_fmri_task_main(ts, varargin)

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
%        what is ts?
%
% :Optional Inputs: Enter keyword followed by variable with values
%
%   **'response':**
%        response{i}{j}: j'th response for i'th seed word
%                - The seed word should be saved as the first (response{i}{1}) response.
%   **'test':**
%        This will give you a smaller screen to test your code.
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
% ts{j} = {{'w1', 'w2'}, [6], [0]} -> no rating
% ts{j} = {{'w1', 'w2'}, [6], [6]} -> rating
% ..
%    Copyright (C) 2017  Wani Woo (Cocoan lab)
% ..
%% default setting
testmode = false;
practice_mode = false;

USE_EYELINK = false;
USE_BIOPAC = false;
savedir = fullfile(pwd, 'data');

scriptdir = pwd; % modify this

%% parsing varargin
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'test', 'testmode'}
                testmode = true;
            case {'savedir'}
                savedir = varargin{i+1};
            case {'scriptdir'}
                scriptdir = varargin{i+1};
            case {'eyelink', 'eye', 'eyetrack'}
                USE_EYELINK = true;
            case {'biopac'}
                USE_BIOPAC = true;
                channel_n = 1;
                biopac_channel = 0;
                ljHandle = BIOPAC_setup(channel_n); % BIOPAC SETUP
            case {'practice'}
                practice_mode = true;
        end
    end
end

cd(scriptdir);

%% SETUP: global
global theWindow W H; % window property
global white red orange blue bgcolor; % color
global fontsize window_rect lb rb tb bb anchor_xl anchor_xr anchor_yu anchor_yd scale_H; % rating scale

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

font = 'NanumGothic';
fontsize = 30;

white = 255;
red = [189 0 38];
blue = [0 85 169];
orange = [255 164 0];

% rating scale left and right bounds 1/3 and 2/3
lb = 1.5*W/5; % in 1280, it's 384
rb = 3.5*W/5; % in 1280, it's 896 rb-lb = 512

% rating scale upper and bottom bounds 1/4 and 3/4
tb = H/5+100;           % in 800, it's 210
bb = H/2+100;           % in 800, it's 450, bb-tb = 240
scale_H = (bb-tb).*0.15;

%% SETUP: DATA and Subject INFO
if ~practice_mode % if not practice mode, save the data
    
    [fname, start_line, SID, SessID] = subjectinfo_check(savedir, 'task'); % subfunction
    
    % add some task information
    data.version = 'FAST_fmri_task_v1_11-05-2017';
    data.github = 'https://github.com/cocoanlab/fast_fmri';
    data.subject = SID;
    data.session = SessID;
    data.wordfile = fullfile(savedir, ['a_worddata_sub' SID '_sess' SessID '.mat']);
    data.responsefile = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);
    data.taskfile = fullfile(savedir, ['c_taskdata_sub' SID '_sess' SessID '.mat']);
    data.surveyfile = fullfile(savedir, ['d_surveydata_sub' SID '_sess' SessID '.mat']);
    data.restingfile = fullfile(savedir, ['e_restingdata_sub' SID '.mat']);
    data.exp_starttime = datestr(clock, 0); % date-time: timestamp
    
    % initial save of trial sequence and data
    save(data.taskfile, 'ts', 'data');
end

%% SETUP: Eyelink

% need to be revised when the eyelink is here.
if USE_EYELINK
    edf_filename = ['eyelink_sub' SID '_sess' SessID];
    eyelink_main(edf_filename, 'Init');
    
    status = Eyelink('Initialize');
    if status
        error('Eyelink is not communicating with PC. Its okay baby.');
    end
    Eyelink('Command', 'set_idle_mode');
    waitsec_fromstarttime(GetSecs, .5);
end


%% TASK START

try
    % START: Screen
	theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
    Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
    Screen('TextFont', theWindow, font); 
    Screen('TextSize', theWindow, fontsize);
    HideCursor;
    
    %% PROMPT SETUP:
    practice_prompt = double('연습을 해보겠습니다.\n여러 개의 감정 단어들이 나타나면 5초 안에\n트랙볼로 커서를 움직여 아무 단어나 클릭하시면 됩니다.\n\n준비되셨으면 버튼을 눌러주세요');
    pre_scan_prompt{1} = double('이제부터 여러분이 방금 말씀하셨던 단어들을 순서대로 보게 될 것입니다.');
    pre_scan_prompt{2} = double('각 단어들을 15초 동안 보여드릴텐데 그 시간동안 그 단어들이');
    pre_scan_prompt{3} = double('여러분에게 어떤 의미로 다가오는지 자연스럽게 생각해보시기 바랍니다.');
    pre_scan_prompt{4} = double('이후 여러 개의 감정 단어들이 등장하면 5초 안에');
    pre_scan_prompt{5} = double('여러분이 현재 느끼는 감정과 가장 가까운 단어를 선택하시면 됩니다.');
    pre_scan_prompt{6} = double('\n준비되셨으면 버튼을 클릭해주세요.');
    exp_start_prompt = double('실험자는 모든 것이 잘 준비되었는지 체크해주세요 (Biopac, Eyelink, 등등).\n모두 준비되었으면, 스페이스바를 눌러주세요.');
    ready_prompt = double('참가자가 준비되었으면, 이미징을 시작합니다 (s).');
    run_end_prompt = double('잘하셨습니다. 잠시 대기해 주세요.');
    
    %% PRACTICE RATING: Test trackball, Practice emotion rating
    
    % viewing the practice prompt until click. 
    if practice_mode
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
        WaitSecs(.3)
        emotion_rating(GetSecs); % sub-function: 5s
        concent_rating(GetSecs);
        
        % practice end
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        DrawFormattedText(theWindow, run_end_prompt, 'center', 'center', white, [], [], [], 1.5);
        Screen('Flip', theWindow);
        WaitSecs(2);
        
        ShowCursor; %unhide mouse
        Screen('CloseAll'); 
    end
    
    %% DISPLAY PRESCAN MESSAGE
    while (1)
        [~, ~, button] = GetMouse(theWindow);
        [~,~,keyCode] = KbCheck;
        
        if button(1)
            break
        elseif keyCode(KbName('q'))==1
            abort_man;
        end
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        for i = 1:numel(pre_scan_prompt)
            DrawFormattedText(theWindow, pre_scan_prompt{i},'center', textH-40*(2-i), white);
        end
        Screen('Flip', theWindow);
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
        DrawFormattedText(theWindow, exp_start_prompt, 'center', 'center', white, [], [], [], 1.5);
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
    data.runscan_starttime = GetSecs; % run start timestamp
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double('시작합니다...'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(data.runscan_starttime, 4);
    
    % Blank
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
        
    %% EYELINK AND BIOPAC SETUP
    
    if USE_EYELINK
        Eyelink('StartRecording');
        data.eyetracker_starttime = GetSecs; % eyelink timestamp
    end
        
    if USE_BIOPAC
        data.biopac_starttime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(data.biopac_starttime, 1);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    % 10 seconds from the runstart
    waitsec_fromstarttime(data.runscan_starttime, 10);
    
    
    %% MAIN TASK 1. SHOW 2 WORDS, WORD PROMPT
    wordT = 1;   % duration for showing target words
    cqT = 9;     % duration for question of concentration
    for ts_i = 1:numel(ts)   % repeat for 40 trials
        data.dat{ts_i}.trial_starttime = GetSecs; % trial start timestamp
        display_target_word(ts{ts_i}{1}); % sub-function, display two generated words
        waitsec_fromstarttime(data.dat{ts_i}.trial_starttime, wordT); % for 15s
         
        % Blank for ISI
        data.dat{ts_i}.isi_starttime = GetSecs;  % ISI start timestamp
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(data.dat{ts_i}.trial_starttime, wordT+ts{ts_i}{2});
        
        % Emotion Rating
        if ts{ts_i}{3} ~=0   % if 3rd column of ts is not 0, do rating for 5s
            data.dat{ts_i}.rating_starttime = GetSecs;  % rating start timestamp
            [data.dat{ts_i}.rating_emotion_word, data.dat{ts_i}.rating_trajectory_time, ...
                data.dat{ts_i}.rating_trajectory] = emotion_rating(data.dat{ts_i}.rating_starttime); % sub-function
            
            % Blank for ITI
            data.dat{ts_i}.iti_starttime = GetSecs;    % ITI start timestamp
            Screen(theWindow,'FillRect',bgcolor, window_rect);
            Screen('Flip', theWindow);
            waitsec_fromstarttime(data.dat{ts_i}.trial_starttime, wordT+ts{ts_i}{2}+5+ts{ts_i}{3});
        end

        % Concentration Qustion
        if ts{ts_i}{4} ~=0   % if 4rd column of ts is not 0, ask concentration for 9(ct)+3s
            data.dat{ts_i}.concent_starttime = GetSecs;  % rating start timestamp
            [data.dat{ts_i}.rating_concent, data.dat{ts_i}.rating_concent_time, ...
                data.dat{ts_i}.rating_trajectory] = concent_rating(data.dat{ts_i}.concent_starttime); % sub-function
            
            % Blank for ITI
            data.dat{ts_i}.iti_starttime = GetSecs;    % ITI start timestamp
            Screen(theWindow,'FillRect',bgcolor, window_rect);
            Screen('Flip', theWindow);
            waitsec_fromstarttime(data.dat{ts_i}.iti_starttime, wordT+ts{ts_i}{2}+cqT+3+ts{ts_i}{4});
        end

        % save data every even trial
        if mod(ts_i, 2) == 0 
            save(data.taskfile, 'data', '-append'); % 'append' overwrite with adding new columns to 'data'
        end
        
    end
    
    %% RUN END MESSAGE

        Screen(theWindow,'FillRect',bgcolor, window_rect);
        DrawFormattedText(theWindow, run_end_prompt, 'center', 'center', white, [], [], [], 1.5);
        Screen('Flip', theWindow);
    
    save(data.taskfile, 'data', '-append');
    
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

global W H white theWindow window_rect bgcolor

fontsize = [45 65];
% Calcurate the W & H of two generated words
Screen('TextSize', theWindow, fontsize(1));
[response_W(1), response_H(1)] = Screen(theWindow, 'DrawText', double(words{1}), 0, 0);

Screen('TextSize', theWindow, fontsize(2));
[response_W(2), response_H(2)] = Screen(theWindow, 'DrawText', double(words{2}), 0, 0);

interval = 150;  % between two words
% coordinates of the words 
x(1) = W/2 - interval/2 - response_W(1);
x(2) = W/2 + interval/2;

y(1) = H/2 - response_H(1);
y(2) = H/2 - response_H(2);

Screen(theWindow,'FillRect',bgcolor, window_rect);

Screen('TextSize', theWindow, fontsize(1)); % previous word, fontsize = 45
DrawFormattedText(theWindow, double(words{1}), x(1), y(1), white, [], [], [], 1.5);

Screen('TextSize', theWindow, fontsize(2)); % present word, fontsize = 65
DrawFormattedText(theWindow, double(words{2}), x(2), y(2), white, [], [], [], 1.5);

Screen('Flip', theWindow);

end

function [emotion_word, trajectory_time, trajectory] = emotion_rating(starttime)

global W H orange bgcolor window_rect theWindow red

rng('shuffle');        % it prevents pseudo random number
rand_z = randperm(14); % random seed
[choice, xy_rect] = display_emotion_words(rand_z);

SetMouse(W/2, H/2);

trajectory = [];
trajectory_time = [];

j = 0;

while(1)
    j = j + 1;
    [x, y, button] = GetMouse(theWindow);
    
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    display_emotion_words(rand_z);
    Screen('DrawDots', theWindow, [x y], 10, orange, [0, 0], 1); % draw orange dot on the cursor
    Screen('Flip', theWindow);
    
    trajectory(j,:) = [x y];                  % trajectory of location of cursor
    trajectory_time(j) = GetSecs - starttime; % trajectory of time
    
    if trajectory_time(end) >= 5  % maximum time of rating is 5s
        button(1) = true;
    end
    
    if button(1)  % After click, the color of cursor dot changes.
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        display_emotion_words(rand_z);
        Screen('DrawDots', theWindow, [x;y], 10, red, [0 0], 1);
        Screen('Flip', theWindow);
        
        % which word based on x y from mouse click
        choice_idx = x > xy_rect(:,1) & x < xy_rect(:,3) & y > xy_rect(:,2) & y < xy_rect(:,4);
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
intro_prompt2 = double('10초 안에 트랙볼을 움직여서 집중하고 있는 정도를 클릭해주세요.');
end_prompt = double('과제가 다시 이어집니다. 집중해주세요.');

title={'전혀 기울이지 않음','보통', '매우 집중하고 있음'};

SetMouse(W/4, H/2);

trajectory = [];
trajectory_time = [];
xy = [W/4 W*3/4 W/4 W/4 W*3/4 W*3/4;
      H/2 H/2 H/2-7 H/2+7 H/2-7 H/2+7];

j = 0;

while(1)
    j = j + 1;
    [mx, my, button] = GetMouse(theWindow);
    
    x = mx;
    y = H/2;
    if x < W/4, x = W/4;
    elseif x > W*3/4, x = W*3/4;
    end
    
    Screen('TextSize', theWindow, fontsize);
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('DrawLines',theWindow, xy, 5, 255);
    DrawFormattedText(theWindow, intro_prompt1,'center', H/4, white);
    DrawFormattedText(theWindow, intro_prompt2,'center', H/4+40, white);
    % Draw scale letter
    DrawFormattedText(theWindow, double(title{1}),'center', 'center', white, ...
                [],[],[],[],[], [xy(1,1)-15, xy(2,1), xy(1,1)+20, xy(2,1)+60]);
    DrawFormattedText(theWindow, double(title{2}),'center', 'center', white, ...
                [],[],[],[],[], [W/2-15, xy(2,1), W/2+20, xy(2,1)+60]);
    DrawFormattedText(theWindow, double(title{3}),'center', 'center', white, ...
                [],[],[],[],[], [xy(1,2)-15, xy(2,1), xy(1,2)+20, xy(2,1)+60]);

    Screen('DrawDots', theWindow, [x y], 10, orange, [0, 0], 1); % draw orange dot on the cursor
    Screen('Flip', theWindow);
        
    trajectory(j,:) = [(x-xy(1,1))/(W/2)];    % trajectory of location of cursor
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
            [],[],[],[],[], [xy(1,1)-15, xy(2,1), xy(1,1)+20, xy(2,1)+60]);
        DrawFormattedText(theWindow, double(title{2}),'center', 'center', white, ...
            [],[],[],[],[], [W/2-15, xy(2,1), W/2+20, xy(2,1)+60]);
        DrawFormattedText(theWindow, double(title{3}),'center', 'center', white, ...
            [],[],[],[],[], [xy(1,2)-15, xy(2,1), xy(1,2)+20, xy(2,1)+60]);
        Screen('DrawDots', theWindow, [x;y], 10, red, [0 0], 1);
        Screen('Flip', theWindow);
        
        concentration = (x-xy(1,1))/(W/2);  % 0~1
        
        WaitSecs(0.3);   
        break;
    end    
end

Screen(theWindow, 'FillRect', bgcolor, window_rect);
DrawFormattedText(theWindow, end_prompt, 'center', 'center', white);
Screen('Flip', theWindow);
WaitSecs(2.7);

end