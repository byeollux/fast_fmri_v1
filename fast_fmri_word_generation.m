function wgdata = fast_fmri_word_generation(seed, varargin)

% Run a word generation step of Free Association Semantic Task with the fMRI scanning.
%
% :Usage:
% ::
%
%    wgdata = fast_fmri_word_generation(seed, varargin)
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
%   **wgdata:**
%        data file
%
%
% :Examples:
% ::
%
%    seed = '나무';
%    wgdata = fast_fmri_word_generation(seed, 'eyelink', 'biopac'); % default for fMRI
%
%    wgdata = fast_fmri_word_generation(seed, 'repeat', 5); % repeat only 5 times
%
%    wgdata = fast_fmri_word_generation(seed, 'practice'); % practice mode (only 5 beeps)
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
practice_mode = false;
USE_EYELINK = false;
USE_BIOPAC = false;
savewav = false;
savedir = fullfile(pwd, 'data');
response_repeat = 40;   % 40
restingtime = 120;      % 120sec
wgdata = [];

addpath(genpath(pwd));
%% PARSING OUT OPTIONAL INPUT
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'practice'}
                practice_mode = true;
            case {'eyelink', 'eye', 'eyetrack'}
                USE_EYELINK = true;
            case {'biopac'}
                USE_BIOPAC = true;
                channel_n = 1;
                biopac_channel = 0;
                ljHandle = BIOPAC_setup(channel_n); % BIOPAC SETUP
            case {'test', 'testmode'}
                testmode = true;
            case {'savedir'}
                savedir = varargin{i+1};
            case {'repeat'}
                response_repeat = varargin{i+1};
            case {'savewav'}
                savewav = true;
        end
    end
end

%% SETUP: global
global theWindow W H; % window property
global white red orange bgcolor; % color
global window_rect; % rating scale

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


W = window_rect(3); % width of screen
H = window_rect(4); % height of screen
textH = H/2.3;
tb = H/5;

% font = 'NanumGothic';
fontsize = 30;

white = 255;
red = [158 1 66];
orange = [255 164 0];

linexy1 = [W/4 W*3/4 W/4 W/4 W/2 W/2 W*3/4 W*3/4;
    H/2 H/2 H/2-7 H/2+7 H/2-7 H/2+7 H/2-7 H/2+7];
linexy2 = [W*3/8 W*5/8 W*3/8 W*3/8 W*5/8 W*5/8;
    H/2 H/2 H/2-7 H/2+7 H/2-7 H/2+7];

%% SETUP: DATA and Subject INFO
if ~practice_mode
    [fname, ~, SID, SessID] = subjectinfo_check(savedir, 'word'); % subfunction
    
    if exist(fname, 'file'), load(fname, 'wgdata'); end
    
    % add some task information
    wgdata.version = 'FAST_fmri_wordgeneration_v1_02-19-2018';
    wgdata.github = 'https://github.com/ByeolEtoileKim/fast_fmri_v1';
    wgdata.subject = SID;
    wgdata.session = SessID;
    wgdata.wordfile = fullfile(savedir, ['a_worddata_sub' SID '_sess' SessID '.mat']);
    wgdata.responsefile = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);
    wgdata.taskfile = fullfile(savedir, ['c_taskdata_sub' SID '_sess' SessID '.mat']);
    wgdata.surveyfile = fullfile(savedir, ['d_surveydata_sub' SID '.mat']);
    wgdata.restingfile = fullfile(savedir, ['e_restingdata_sub' SID '.mat']);
    wgdata.exp_starttime = datestr(clock, 0); % date-time: timestamp
    wgdata.seeds = seed;
    
    response = cell(41,1); % preallocate the cell structure
    response{1} = seed{str2double(SessID)};
    

    wgdata.rest.rating = cell(3,7);
    question_type = {'Valence','Self','Time','Vividness','Safe&Threat','Wordrelevance'};
    for i = 1:6
        wgdata.rest.rating{1,i} = question_type{i};
    end
    wgdata.rest.rating{3,7} = 'RT';
    
    % initial save the data
    save(wgdata.wordfile, 'wgdata');
    save(wgdata.responsefile, 'response');
end

%% START: Screen
theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect); % start the screen
Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
% Screen('TextFont', theWindow, font);
Screen('TextSize', theWindow, fontsize);
HideCursor;

%% SETUP: Eyelink
% need to be revised when the eyelink is here.
if USE_EYELINK
    edf_filename = ['W_' SID '_' SessID]; % name should be equal or less than 8
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
    practice_prompt{1} = double('녹음 테스트를 해보겠습니다.');
    practice_prompt{2} = double('단어가 보이고 벨이 울리면 말씀해주세요. 2번 반복됩니다.');
    practice_prompt{3} = double('\n준비되시면 시작하겠습니다.');
    
    intro_prompt{1} = double('지금부터 자유연상 과제를 시작하겠습니다.');
    intro_prompt{2} = double('2.5초마다 벨이 울리면 바로 떠오르는 단어나 문장을 말씀해주세요.');
    intro_prompt{3} = double('떠오르지 않을 경우 전에 말한 내용을 반복해서 말할 수 있습니다.');
    intro_prompt{4} = double('말을 할 때에는 또박또박 크게 말씀해주세요');
    intro_prompt{7} = double('실험자는 모든 것이 잘 준비되었는지 체크해주세요 (Biopac, Eyelink, 등등).\n\n모두 준비되었으면, 스페이스바를 눌러주세요.');
    
    resting_intro = double('이제 2분간 쉬는 동안의 뇌 활동을 찍는 과제를 하겠습니다.');
    
    title={'방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 일으킨 감정은 무엇인가요?',...
        '방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 나와 관련이 있는 정도는 어느 정도인가요?',...
        '방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 가장 관련이 있는 자신의 시간은 언제인가요?', ...
        '방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 어떤 상황이나 장면을 생생하게 떠올리게 했나요?',...
        '방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 안전 또는 위협을 의미하거나 느끼게 했나요?',...
        '방금 쉬는 과제를 하는 동안 자연스럽게 떠올린 생각에 대한 질문입니다.\n\n그 생각이 방금 연상한 단어와 관련된 생각이었나요?';
        '부정', '전혀 나와\n관련이 없음', '과거', '전혀 생생하지 않음', '위협', '전혀 관련 없음';
        '중립', '', '현재', '', '중립', '';
        '긍정','나와 관련이\n매우 많음', '미래','매우 생생함','안전','매우 관련 있음'};
   
    ready_prompt = double('참가자가 준비되었으면, 이미징을 시작합니다 (s).');
    run_end_prompt = double('잘하셨습니다. 잠시 대기해 주세요.');
    
    %% TEST RECORDING... and play
    if practice_mode
        % Recording Setting
        InitializePsychSound;
        pahandle = PsychPortAudio('Open', [], 2, 0, 44100, 2);
        % Sound recording: Preallocate an internal audio recording  buffer with a capacity of 10 seconds
        PsychPortAudio('GetAudioData', pahandle, 10);
        
        while (1)
            [~,~,keyCode] = KbCheck;
            if keyCode(KbName('space'))==1
                break
            elseif keyCode(KbName('q'))==1
                abort_man;
            end
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            for i = 1:numel(practice_prompt)
                DrawFormattedText(theWindow, practice_prompt{i},'center', textH-50*(2-i), white);
            end
            Screen('Flip', theWindow);
        end
        
        % Showing seed word, beeping, recording X 2 times
        for n = 1:2
            % seed word for 2.5s
            if n == 1
                Screen('FillRect', theWindow, bgcolor, window_rect);
                Screen('TextSize', theWindow, fontsize*2); % emphasize
                DrawFormattedText(theWindow, double('테스트'),'center', textH, orange);
                Screen('Flip', theWindow);
                waitsec_fromstarttime(GetSecs, 2.5);
            end
            
            % start recording
            PsychPortAudio('Start', pahandle, 0, 0, 1);
            Screen('FillRect', theWindow, bgcolor, window_rect);
            Screen('Flip', theWindow);
            
            % beeping
            beep = MakeBeep(1000,.2);
            Snd('Play',beep);
            
            % cross for 1s
            Screen('FillRect', theWindow, bgcolor, window_rect);
            Screen('TextSize', theWindow, fontsize*1.2); % emphasize
            DrawFormattedText(theWindow, '+', 'center', textH, white);
            Screen('Flip', theWindow);
            waitsec_fromstarttime(GetSecs, 1)
            
            % blank for 1.5s
            Screen('FillRect', theWindow, bgcolor, window_rect);
            Screen('Flip', theWindow);
            waitsec_fromstarttime(GetSecs, 1.5)
            
            % stop recording
            PsychPortAudio('Stop', pahandle);
            wgdata.test_audiodata{n} = PsychPortAudio('GetAudioData', pahandle);
        end
        
        PsychPortAudio('Close', pahandle);
        
        Screen('FillRect', theWindow, bgcolor, window_rect);
        Screen('TextSize', theWindow, fontsize);
        DrawFormattedText(theWindow, run_end_prompt,'center', textH, white);
        Screen('Flip', theWindow);
        
        % play the 2 sounds
        for z=1:2
            WaitSecs(0.2);
            players = audioplayer(wgdata.test_audiodata{z}', 44100);
            play(players);
            WaitSecs(3);
        end
        
        WaitSecs(3);
        Screen('CloseAll');
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
        for i = 1:numel(intro_prompt)
            DrawFormattedText(theWindow, intro_prompt{i},'center', textH-40*(3-i), white);
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
    wgdata.runscan_starttime = GetSecs; % run start timestamp
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double('시작합니다...'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(wgdata.runscan_starttime, 4);
    
    % 6 seconds: Blank
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
    
    %% EYELINK AND BIOPAC START
    
    if USE_EYELINK
        Eyelink('StartRecording');
        wgdata.eyetracker_starttime = GetSecs; % eyelink timestamp
        Eyelink('Message','WG Run start');
    end
    
    if USE_BIOPAC
        wgdata.biopac_starttime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(wgdata.biopac_starttime, 0.8);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    %% SOUND RECORDING INIT
    InitializePsychSound; % it's saved in run_FAST_fmri_main.m because it
    % should be run only once for the entire scan.
    % Maybe, with windows, we can have this here.
    
    pahandle = PsychPortAudio('Open', [], 2, 0, 44100, 2);
    % Sound recording: Preallocate an internal audio recording  buffer with a capacity of 10 seconds
    PsychPortAudio('GetAudioData', pahandle, 10);
    
    % 10 seconds from the runstart
    waitsec_fromstarttime(wgdata.runscan_starttime, 10);
    
    
    %% MAIN PART of the experiment
    
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, '+','center', textH, white);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(wgdata.runscan_starttime, 11);
    
    wgdata.seedword_starttime = GetSecs; % seed word timestamp
    time_fromstart = 5:2.5:102.5;
    
    % Showing seed word, beeping, recording
    for response_n = 1:response_repeat
        
        % seed word for 2.5s
        if response_n == 1
            Screen('FillRect', theWindow, bgcolor, window_rect);
            Screen('TextSize', theWindow, fontsize*2); % emphasize
            DrawFormattedText(theWindow, double(seed{str2double(SessID)}),'center', textH, orange);
            Screen('Flip', theWindow);
            waitsec_fromstarttime(wgdata.seedword_starttime, 2.5);
            if USE_EYELINK
                Eyelink('Message','WG SeedWord');
            end
        end
        
        % start recording
        PsychPortAudio('Start', pahandle, 0, 0, 1);
        
        Screen('FillRect', theWindow, bgcolor, window_rect);
        Screen('Flip', theWindow);
        
        % beeping
        beep = MakeBeep(1000,.2);
        Snd('Play',beep);
        wgdata.beeptime_from_start(response_n,1) = GetSecs-wgdata.seedword_starttime;
        
        % cross for 1s
        Screen('FillRect', theWindow, bgcolor, window_rect);
        Screen('TextSize', theWindow, fontsize*1.2); % emphasize
        DrawFormattedText(theWindow, '+', 'center', textH, white);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(wgdata.seedword_starttime, time_fromstart(response_n)-1.5)
        
        % blank for 1.5s
        Screen('FillRect', theWindow, bgcolor, window_rect);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(wgdata.seedword_starttime, time_fromstart(response_n))
        
        % stop recording
        PsychPortAudio('Stop', pahandle);
        wgdata.audiodata{response_n} = PsychPortAudio('GetAudioData', pahandle);
        if USE_EYELINK
            Eyelink('Message','WG Trial end');
        end
    end
    
    wgdata.response{1} = seed{str2double(SessID)};
    save(wgdata.wordfile, 'wgdata');
    
    %% DISPLAY RESTING START MESSAGE
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, resting_intro,'center', textH, white);
    Screen('Flip', theWindow);
    
    if USE_BIOPAC
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(GetSecs, 0.5);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
   
    waitsec_fromstarttime(GetSecs, 5)
    
    %% RESTING
    wgdata.rest.resting_starttime = GetSecs;
    if USE_EYELINK
        Eyelink('Message','Rest start');
    end
    
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, '+','center', 'center', white);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(wgdata.rest.resting_starttime, restingtime);
    wgdata.rest.resting_endtime = GetSecs;
    
    if USE_EYELINK
        Eyelink('Message','Rest end');
    end
    
    
    %% RESTING QESTION
    rng('shuffle');
    z = [6, randperm(5)];
    
    for i = 1:numel(z)
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
                    wgdata.rest.rating{2,z(i)} = (x-W/2)/(W/4);
                    wgdata.rest.rating{3,z(i)} = GetSecs-question_start;
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
                    wgdata.rest.rating{2,z(i)} = (x-W*3/8)/(W/4);
                    wgdata.rest.rating{3,z(i)} = GetSecs-question_start;
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
                    break;
                end
            end
        end
    end
    WaitSecs(.1);
    
    
    %% RUN END MESSAGE
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, run_end_prompt, 'center', textH, white);
    Screen('Flip', theWindow);
    
    save(wgdata.wordfile, 'wgdata','-append');
    
    if USE_EYELINK
        Eyelink('Message','WG+Resting Run end');
        eyelink_main(edfFile, 'Shutdown');
    end
    if USE_BIOPAC
        wgdata.biopac_endtime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(wgdata.biopac_endtime, 0.1);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    %% Close the audio device:
    
    PsychPortAudio('Close', pahandle);
    
    if ~practice_mode && savewav
        [wavedir, wavefname] = fileparts(fname);
        wave_savename = fullfile(wavedir, [wavefname '.wav']);
        audiowrite(wave_savename,cat(2,wgdata.audiodata{:})',44100);
    end
    
    % close screen
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