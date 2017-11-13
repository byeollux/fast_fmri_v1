function rest = fast_fmri_resting(duration, varargin)

% Run a word generation step of Free Association Semantic Task with the fMRI scanning. 
%
% :Usage:
% ::
%
%    out = fast_fmri_word_generation(seed, varargin)
%
%
% :Inputs:
%
%   **seed:**
%        One word as string, e.g., seed = '나무';
%
%
% :Optional Inputs: Enter keyword followed by variable with values
%
%   **'practice':**
%        This mode plays only 5 beeps, and do not record the responses.
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
%   **'test':**
%        This will give you a smaller screen to test your code.
%
%   **'repeat':**
%        You can specify the number of repeats.
%
%   **'psychtoolbox':**
%        You can specify the psychtoolbox directory. 
%
%   **'savewav':**
%        You can choose to save or not to save wav files.
%
%
% :Output:
%
%   **out:**
%        data file
%
%
% :Examples:
% ::
%
%    seed = '나무';
%    out = fast_fmri_word_generation(seed, 'eyelink', 'biopac'); % default for fMRI
%
%    out = fast_fmri_word_generation(seed, 'repeat', 5); % repeat only 5 times    
%
%    out = fast_fmri_word_generation(seed, 'practice'); % practice mode (only 5 beeps)
%
% ..
%    Copyright (C) 2017 COCOAN lab
% ..
%
%    If you have any questions, please email to: 
%
%          Byeol Kim (roadndream@naver.com) or
%          Wani Woo (waniwoo@skku.edu)
%

%% default setting
testmode = false;
USE_EYELINK = false;
USE_BIOPAC = false;
savedir = fullfile(pwd, 'data');
rest = [];
psychtoolboxdir = '/Users/byeoletoile/Documents/MATLAB/Psychtoolbox';

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

%% SETUP: global
global theWindow W H; % window property
global white red orange bgcolor; % color
global fontsize window_rect lb tb recsize rec barsize; % rating scale

%% SETUP: Screen

addpath(genpath(psychtoolboxdir));

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


W = window_rect(3); % width of screen
H = window_rect(4); % height of screen
textH = H/2.3;

font = 'NanumGothic';
fontsize = 30;

white = 255;
red = [189 0 38];
orange = [255 164 0];

lb=W*14/128;    % 140        when W=1280
tb=H*18/80;     % 180

recsize=[W*500/1280 H*175/800]; 
barsize=[W*340/1280, W*180/1280, W*340/1280, W*180/1280, W*340/1280, 0;
    10, 10, 10, 10, 10, 0; 10, 0, 10, 0, 10, 0;
    10, 10, 10, 10, 10, 0; 1, 2, 3, 4, 5, 0];
rec=[lb,tb; lb+recsize(1),tb; lb,tb+recsize(2); lb+recsize(1),tb+recsize(2);
    lb,tb+2*recsize(2); lb+recsize(1),tb+2*recsize(2)]; %6개 사각형의 왼쪽 위 꼭짓점의 좌표


%% SETUP: DATA and Subject INFO
   
    [fname, ~, SID, SessID] = subjectinfo_check(savedir, 'resting'); % subfunction
    
    if exist(fname, 'file'), load(fname, 'out'); end
      
    % add some task information
    rest.version = 'FAST_fmri_wordgeneration_v1_11-09-2017';
    rest.github = 'https://github.com/ByeolEtoileKim/fast_fmri_v1';
    rest.subject = SID;
    rest.wordfile = fullfile(savedir, ['a_worddata_sub' SID '_sess' SessID '.mat']);
    rest.responsefile = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);
    rest.taskfile = fullfile(savedir, ['c_taskdata_sub' SID '_sess' SessID '.mat']);
    rest.surveyfile = fullfile(savedir, ['d_surveydata_sub' SID '_sess' SessID '.mat']);
    rest.restingfile = fullfile(savedir, ['e_restingdata_sub' SID '.mat']);    
    rest.exp_starttime = datestr(clock, 0); % date-time: timestamp
    
    rest.data = cell(1, 6);
  
    % initial save the data
    save(rest.restingfile, 'rest');

%% SETUP: Eyelink

if USE_EYELINK
    edf_filename = ['YRest_sub' SID '_sess' SessID];
    eyelink_main(edf_filename, 'Init');
    
    status = Eyelink('Initialize');
    if status
        error('Eyelink is not communicating with PC. Its okay baby.');
    end
    Eyelink('Command', 'set_idle_mode');
    waitsec_fromstarttime(GetSecs, .5);
end

%% TAST START: ===========================================================

try
    %% START: Screen
	theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
    Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
    Screen('TextFont', theWindow, font);
    Screen('TextSize', theWindow, fontsize);
    HideCursor;
    
    %% PROMPT SETUP:
    exp_start_prompt = double('실험자는 모든 것이 잘 준비되었는지 체크해주세요 (Biopac, Eyelink, 등등).\n모두 준비되었으면, 스페이스바를 눌러주세요.');
    if duration ==2
        intro_prompt{1} = double('이제 2분간 쉬는 동안의 뇌 활동을 찍는 과제를 하겠습니다.');
    else
    intro_prompt{1} = double('이제 6분간 쉬는 동안의 뇌 활동을 찍는 과제를 하겠습니다.');
    intro_prompt{2} = double('이 과제에서는 눈은 자연스럽게 떠 주시고 화면을 바라봐 주세요.');
    intro_prompt{3} = double('시작하시려면 버튼을 눌러주세요.');
    end 
    
    ready_prompt = double('참가자가 준비되었으면, 이미징을 시작합니다 (s).');
    question_prompt = double('방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.'); 
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
        DrawFormattedText(theWindow, exp_start_prompt, 'center', 'center', white, [], [], [], 1.5);
        Screen('Flip', theWindow);
    end
    
        %% DISPLAY INTRO MESSAGE    
        while (1)
            [~, ~, button] = GetMouse(theWindow);
            [~,~,keyCode] = KbCheck;
            
            if button(1)
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
        waitsec_fromstarttime(GetSecs, .3);
           
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
    rest.data{SessID}.runscan_starttime = GetSecs; % run start timestamp
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double('시작합니다...'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(rest.data{SessID}.runscan_starttime, 4);
    
    % 4 seconds: Blank
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
                
    %% EYELINK AND BIOPAC SETUP
    if USE_EYELINK
        Eyelink('StartRecording');
        rest.data{SessID}.eyetracker_starttime = GetSecs; % eyelink timestamp
        Eyelink('Message','Resting Run start');
    end
        
    if USE_BIOPAC
        rest.data{SessID}.biopac_starttime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(rest.data{SessID}.biopac_starttime, 1);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    %% RESTING
    rest.data{SessID}.resting_starttime = GetSecs; 
    if USE_EYELINK
        Eyelink('Message','Rest start');
    end

    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, '+','center', 'center', white);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(rest.data{SessID}.resting_starttime, duration*60);

       
    if USE_EYELINK
        Eyelink('Message','Rest end');
    end
    
    %% QESTION
    z = randperm(6);
    barsize = barsize(:,z);

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
                display_survey(z, 1, 1, question_prompt,'resting');
                Screen('DrawDots', theWindow, [x;y], 9, orange, [0 0], 1);
                Screen('Flip', theWindow);
                
                if button(1)
                    rest.data{SessID}.rating{barsize(5,j)} = rating(x, j);
                    display_survey(z, 1, 1, question_prompt,'resting');
                    Screen('DrawDots', theWindow, [x,y], 9, red, [0 0], 1);
                    Screen('Flip', theWindow);
                    if USE_EYELINK
                        Eyelink('Message','Rest Question response');
                    end
                    
                    WaitSecs(.3);
                    break;
                end
            end
        end
    end
    WaitSecs(.1)

    %% RUN END MESSAGE & SAVE DATA
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    Screen('TextSize', theWindow, fontsize);
    DrawFormattedText(theWindow, run_end_prompt, 'center', textH, white);
    Screen('Flip', theWindow);
    if USE_EYELINK
        Eyelink('Message','Resting Run end');
    end
    
    % save the data
    save(rest.restingfile, 'rest');
    
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

function rx = rating(x, j)

global barsize recsize rec;
% rx start from 0
if mod(barsize(5,j),2) == 0     % Self, Vividness: 0<=rx<=1
    rx = x-(rec(j,1)+(recsize(1)-barsize(1,j))/2)/barsize(1,j);
else                            % Valence, Time, Safety/Threat: -1<=rx<=1
    rx = x-(rec(j,1)+(recsize(1)-barsize(1,j))/2)/(2*barsize(1,j))-1;
end

end
