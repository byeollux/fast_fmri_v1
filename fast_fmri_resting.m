function rest = fast_fmri_resting(duration, varargin)

% Run a resting state of Free Association Semantic Task with the fMRI scanning.
%
% :Usage:
% ::
%
%    rest = fast_fmri_resting(duration, varargin)
%
%
% :Inputs:
%
%   **duration:**
%        duration of resting, minute;
%
%
% :Optional Inputs: Enter keyword followed by variable with values
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
%
% :Output:
%
%   **rest:**
%        data file
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
rest = [];

addpath(genpath(pwd));
%% PARSING OUT OPTIONAL INPUT
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'eyelink', 'eye', 'eyetrack'}
                USE_EYELINK = true;
            case {'biopac'}
                USE_BIOPAC = true;
                channel_n = 1;
                biopac_channel = 0;
                ljHandle = BIOPAC_setup(channel_n); % BIOPAC SETUP
            case {'test'}
                testmode = true;
        end
    end
end

%% SETUP: DATA and Subject INFO
[~, ~, SID] = subjectinfo_check(savedir, 'resting'); % subfunction

% First resting condition, make new file
% add some task information
rest.version = 'FAST_fmri_wordgeneration_v1_02-19-2017';
rest.github = 'https://github.com/ByeolEtoileKim/fast_fmri_v1';
rest.subject = SID;
rest.wordfile = fullfile(savedir, ['a_worddata_sub' SID '_sessnumber.mat']);
rest.responsefile = fullfile(savedir, ['b_responsedata_sub' SID '_sessnumber.mat']);
rest.taskfile = fullfile(savedir, ['c_taskdata_sub' SID '_sessnumber.mat']);
rest.surveyfile = fullfile(savedir, ['d_surveydata_sub' SID '.mat']);
rest.restingfile = fullfile(savedir, ['e_restingdata_sub' SID '.mat']);
rest.exp_starttime = datestr(clock, 0); % date-time: timestamp
rest.rating = cell(3,7);
question_type = {'Valence','Self','Time','Vividness','Safe&Threat'};
for i = 1:5
    rest.rating{1,i} = question_type{i};
end
rest.rating{3,7} = 'RT';
save(rest.restingfile, 'rest');



%% SETUP: global
global theWindow W H; % window property
global white red orange bgcolor; % color
global fontsize window_rect tb; % rating scale

%% SETUP: Screen

bgcolor = 100;

if testmode
    window_rect = [0 0 1200 800]; % in the test mode, use a little smaller screen
else
    % these 5 lines are from CAPS. In case of fMRI+ThinkPad+full
    % screen, these are nessecary and different from Wani's version.
    screens = Screen('Screens');
    window_num = screens(end);
    Screen('Preference', 'SkipSyncTests', 1);
    window_info = Screen('Resolution', window_num);
    window_rect = [0 0 window_info.width window_info.height]; %0 0 1920 1080
end


W = window_rect(3); % width of screen
H = window_rect(4); % height of screen
textH = H/2.3;
tb = H/5;

% font = 'NanumGothic';
fontsize = 30;

white = 255;
red = [189 0 38];
orange = [255 164 0];

%% START: Screen
theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect); % start the screen
Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
% Screen('TextFont', theWindow, font);
Screen('TextSize', theWindow, fontsize);
HideCursor;

%% SETUP: Eyelink

if USE_EYELINK
    edf_filename = ['R0_' SID]; % name should be equal or less than 8
    edfFile = sprintf('%s.EDF', edf_filename);
    eyelink_main(edfFile, 'Init');
    
    status = Eyelink('Initialize');
    if status
        error('Eyelink is not communicating with PC. Its okay baby.');
    end
    Eyelink('Command', 'set_idle_mode');
    waitsec_fromstarttime(GetSecs, .5);
end

%% TAST START: ===========================================================

try
    
    %% PROMPT SETUP:
    intro_prompt{1} = double('이제 6분간 쉬는 동안의 뇌 활동을 찍는 과제를 하겠습니다.');
    intro_prompt{2} = double('실험자는 모든 것이 잘 준비되었는지 체크해주세요 (Biopac, Eyelink, 등등).');
    intro_prompt{3} = double('모두 준비되었으면, 스페이스바를 눌러주세요.');
    
    ready_prompt = double('참가자가 준비되었으면, 이미징을 시작합니다 (s).');
    run_end_prompt = double('잘하셨습니다. 잠시 대기해 주세요.');
    
    %% DISPLAY EXP START MESSAGE
    while (1)
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('space'))==1
            break
        elseif keyCode(KbName('q'))==1
            abort_man;
        end
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        for i = 1:3
            DrawFormattedText(theWindow, intro_prompt{i},'center', H/2-40*(2-i), white);
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
    rest.runscan_starttime = GetSecs; % run start timestamp
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double('시작합니다...'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(rest.runscan_starttime, 4);
    
    % 4 seconds: Blank
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
    
    %% EYELINK AND BIOPAC START
    if USE_EYELINK
        Eyelink('StartRecording');
        rest.eyetracker_starttime = GetSecs; % eyelink timestamp
        Eyelink('Message','Resting Run start');
    end
    
    if USE_BIOPAC
        rest.biopac_starttime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(rest.biopac_starttime, 1);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    %% RESTING
    waitsec_fromstarttime(rest.runscan_starttime, 10); % end of DISDAQ
    rest.resting_starttime = GetSecs;
    if USE_EYELINK
        Eyelink('Message','Rest start');
    end
    
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, '+','center', 'center', white);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(rest.resting_starttime, duration*60);
    rest.resting_endtime = GetSecs;
    
    if USE_EYELINK
        Eyelink('Message','Rest end');
    end
    
    %% QESTION
    title={'방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 일으킨 감정은 무엇인가요?',...
        '방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 나와 관련이 있는 정도는 어느 정도인가요?',...
        '방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 가장 관련이 있는 자신의 시간은 언제인가요?', ...
        '방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 어떤 상황이나 장면을 생생하게 떠올리게 했나요?',...
        '방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 안전 또는 위협을 의미하거나 느끼게 했나요?',...
        '방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 방금 연상한 단어와 관련된 생각이었나요?';
        '부정', '전혀 나와\n관련이 없음', '과거', '전혀 생생하지 않음', '위협', '전혀 관련 없음';
        '중립', '', '현재', '', '중립', '';
        '긍정','나와 관련이\n매우 많음', '미래','매우 생생함','안전','매우 관련 있음'};
    
    linexy1 = [W/4 W*3/4 W/4 W/4 W/2 W/2 W*3/4 W*3/4;
        H/2 H/2 H/2-7 H/2+7 H/2-7 H/2+7 H/2-7 H/2+7];
    linexy2 = [W*3/8 W*5/8 W*3/8 W*3/8 W*5/8 W*5/8;
        H/2 H/2 H/2-7 H/2+7 H/2-7 H/2+7];
    rng('shuffle');
    z = randperm(5);
    
    % if n > 1        % 2nd ~ 5th resting, ask association-related
    %     rest.dat{n}.rating{1,6} = 'Association-related';
    %     question_start = GetSecs;
    %     SetMouse(W*3/8, H/2);
    %
    %     while(1)
    %         % Track Mouse coordinate
    %         [mx, ~, button] = GetMouse(theWindow);
    %
    %         x = mx;
    %         y = H/2;
    %         if x < W*3/8, x = W*3/8;
    %         elseif x > W*5/8, x = W*5/8;
    %         end
    %
    %         Screen(theWindow, 'FillRect', bgcolor, window_rect);
    %         Screen('DrawLines',theWindow, linexy2, 3, 255);
    %         DrawFormattedText(theWindow, double(title{1,6}), 'center', tb, white, [], [], [], 1.5);
    %
    %         DrawFormattedText(theWindow, double(title{2,6}),'center', 'center', white, [],[],[],[],[],...
    %             [linexy2(1,1)-15, linexy2(2,1)+20, linexy2(1,1)+20, linexy2(2,1)+80]);
    %         DrawFormattedText(theWindow, double(title{3,6}),'center', 'center', white, [],[],[],[],[],...
    %             [W/2-15, linexy2(2,1)+20, W/2+20, linexy2(2,1)+80]);
    %         DrawFormattedText(theWindow, double(title{4,6}),'center', 'center', white, [],[],[],[],[],...
    %             [linexy2(1,2)-15, linexy2(2,1)+20, linexy2(1,2)+20, linexy2(2,1)+80]);
    %
    %         Screen('DrawDots', theWindow, [x;y], 9, orange, [0 0], 1);
    %         Screen('Flip', theWindow);
    %
    %         if button(1)
    %             rest.dat{n}.rating{2,6} = (x-W*3/8)/(W/4);
    %             rest.dat{n}.rating{3,6} = GetSecs-question_start;
    %
    %             Screen(theWindow, 'FillRect', bgcolor, window_rect);
    %             Screen('DrawLines',theWindow, linexy2, 3, 255);
    %             DrawFormattedText(theWindow, double(title{1,6}), 'center', tb, white, [], [], [], 1.5);
    %
    %             DrawFormattedText(theWindow, double(title{2,6}),'center', 'center', white, [],[],[],[],[],...
    %                 [linexy2(1,1)-15, linexy2(2,1)+20, linexy2(1,1)+20, linexy2(2,1)+80]);
    %             DrawFormattedText(theWindow, double(title{3,6}),'center', 'center', white, [],[],[],[],[],...
    %                 [W/2-15, linexy2(2,1)+20, W/2+20, linexy2(2,1)+80]);
    %             DrawFormattedText(theWindow, double(title{4,6}),'center', 'center', white, [],[],[],[],[],...
    %                 [linexy2(1,2)-15, linexy2(2,1)+20, linexy2(1,2)+20, linexy2(2,1)+80]);
    %
    %             Screen('DrawDots', theWindow, [x;y], 9, orange, [0 0], 1);
    %             Screen('Flip', theWindow);
    %             if USE_EYELINK
    %                 Eyelink('Message','Rest Question response');
    %             end
    %             WaitSecs(.3);
    %             break;
    %         end
    %     end
    % end
    
    for i = 1:(numel(title(1,:))-1)
        if mod(z(i),2) % odd number, valence, time, safe&threat
            question_start = GetSecs;
            SetMouse(W/2, H/2);
            
            while(1)
                % Track Mouse coordinate
                [mx, ~, button] = GetMouse(theWindow);
                
                x = mx;
                y = H/2;
                if x < W/4, x = W/4;
                elseif x > W*3/4, x = W*3/4;
                end
                Screen(theWindow, 'FillRect', bgcolor, window_rect);
                Screen('DrawLines',theWindow, linexy1, 3, 255);
                DrawFormattedText(theWindow, double(title{1,z(i)}), 'center', tb, white, [], [], [], 1.5);
                DrawFormattedText(theWindow, double(title{2,z(i)}),'center', 'center', white, [],[],[],[],[],...
                    [linexy1(1,1)-15, linexy1(2,1)+20, linexy1(1,1)+20, linexy1(2,1)+80]);
                DrawFormattedText(theWindow, double(title{3,z(i)}),'center', 'center', white, [],[],[],[],[],...
                    [W/2-15, linexy1(2,1)+20, W/2+20, linexy1(2,1)+80]);
                DrawFormattedText(theWindow, double(title{4,z(i)}),'center', 'center', white, [],[],[],[],[],...
                    [linexy1(1,2)-15, linexy1(2,1)+20, linexy1(1,2)+20, linexy1(2,1)+80]);
                
                Screen('DrawDots', theWindow, [x;y], 9, orange, [0 0], 1);
                Screen('Flip', theWindow);
                
                if button(1)
                    rest.rating{2,z(i)} = (x-W/2)/(W/4);
                    rest.rating{3,z(i)} = GetSecs-question_start;
                    rrtt = GetSecs;
                    
                    Screen(theWindow, 'FillRect', bgcolor, window_rect);
                    Screen('DrawLines',theWindow, linexy1, 3, 255);
                    DrawFormattedText(theWindow, double(title{1,z(i)}), 'center', tb, white, [], [], [], 1.5);
                    
                    DrawFormattedText(theWindow, double(title{2,z(i)}),'center', 'center', white, [],[],[],[],[],...
                        [linexy1(1,1)-15, linexy1(2,1)+20, linexy1(1,1)+20, linexy1(2,1)+80]);
                    DrawFormattedText(theWindow, double(title{3,z(i)}),'center', 'center', white, [],[],[],[],[],...
                        [W/2-15, linexy1(2,1)+20, W/2+20, linexy1(2,1)+80]);
                    DrawFormattedText(theWindow, double(title{4,z(i)}),'center', 'center', white, [],[],[],[],[],...
                        [linexy1(1,2)-15, linexy1(2,1)+20, linexy1(1,2)+20, linexy1(2,1)+80]);
                    
                    Screen('DrawDots', theWindow, [x,y], 9, red, [0 0], 1);
                    Screen('Flip', theWindow);
                    if USE_EYELINK
                        Eyelink('Message','Rest Question response');
                    end
                    waitsec_fromstarttime(rrtt, 0.5);
                    rest.rating{4,z(i)} = GetSecs;
                    break;
                end
            end
            
        else   % even number, self-relevance, vividness
            question_start = GetSecs;
            SetMouse(W*3/8, H/2);
            
            while(1)
                % Track Mouse coordinate
                [mx, ~, button] = GetMouse(theWindow);
                
                x = mx;
                y = H/2;
                if x < W*3/8, x = W*3/8;
                elseif x > W*5/8, x = W*5/8;
                end
                
                Screen(theWindow, 'FillRect', bgcolor, window_rect);
                Screen('DrawLines',theWindow, linexy2, 3, 255);
                DrawFormattedText(theWindow, double(title{1,z(i)}), 'center', tb, white, [], [], [], 1.5);
                
                DrawFormattedText(theWindow, double(title{2,z(i)}),'center', 'center', white, [],[],[],[],[],...
                    [linexy2(1,1)-15, linexy2(2,1)+20, linexy2(1,1)+20, linexy2(2,1)+80]);
                DrawFormattedText(theWindow, double(title{3,z(i)}),'center', 'center', white, [],[],[],[],[],...
                    [W/2-15, linexy2(2,1)+20, W/2+20, linexy2(2,1)+80]);
                DrawFormattedText(theWindow, double(title{4,z(i)}),'center', 'center', white, [],[],[],[],[],...
                    [linexy2(1,2)-15, linexy2(2,1)+20, linexy2(1,2)+20, linexy2(2,1)+80]);
                
                Screen('DrawDots', theWindow, [x;y], 9, orange, [0 0], 1);
                Screen('Flip', theWindow);
                
                if button(1)
                    rest.rating{2,z(i)} = (x-W*3/8)/(W/4);
                    rest.rating{3,z(i)} = GetSecs-question_start;
                    rrtt = GetSecs;
                    
                    Screen(theWindow, 'FillRect', bgcolor, window_rect);
                    Screen('DrawLines',theWindow, linexy2, 3, 255);
                    DrawFormattedText(theWindow, double(title{1,z(i)}), 'center', tb, white, [], [], [], 1.5);
                    
                    DrawFormattedText(theWindow, double(title{2,z(i)}),'center', 'center', white, [],[],[],[],[],...
                        [linexy2(1,1)-15, linexy2(2,1)+20, linexy2(1,1)+20, linexy2(2,1)+80]);
                    DrawFormattedText(theWindow, double(title{3,z(i)}),'center', 'center', white, [],[],[],[],[],...
                        [W/2-15, linexy2(2,1)+20, W/2+20, linexy2(2,1)+80]);
                    DrawFormattedText(theWindow, double(title{4,z(i)}),'center', 'center', white, [],[],[],[],[],...
                        [linexy2(1,2)-15, linexy2(2,1)+20, linexy2(1,2)+20, linexy2(2,1)+80]);
                    
                    Screen('DrawDots', theWindow, [x;y], 9, red, [0 0], 1);
                    Screen('Flip', theWindow);
                    if USE_EYELINK
                        Eyelink('Message','Rest Question response');
                    end
                    waitsec_fromstarttime(rrtt, 0.5);
                    rest.rating{4,z(i)} = GetSecs;
                    break;
                end
            end
        end
    end
    WaitSecs(.1);
    
    %% RUN END MESSAGE & SAVE DATA
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    Screen('TextSize', theWindow, fontsize);
    DrawFormattedText(theWindow, run_end_prompt, 'center', textH, white);
    Screen('Flip', theWindow);
    rest.run_endtime = GetSecs;
    
    if USE_EYELINK
        Eyelink('Message','Resting Run end');
        eyelink_main(edfFile, 'Shutdown');
    end
    if USE_BIOPAC
        rest.biopac_endtime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(rest.biopac_endtime, 0.1);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    % save the data
    save(rest.restingfile, 'rest', '-append');
    
    WaitSecs(1);
    
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

