function out = fast_fmri_word_generation(seed, varargin)

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
practice_mode = false;
USE_EYELINK = false;
USE_BIOPAC = false;
savewav = false;
savedir = fullfile(pwd, 'data');
response_repeat = 40;
out = [];
psychtoolboxdir = '/Users/byeoletoile/Documents/MATLAB/Psychtoolbox';

addpath(genpath(psychtoolboxdir));
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
            case {'psychtoolbox'}
                psychtoolboxdir = varargin{i+1};
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

font = 'NanumGothic';
fontsize = 30;

white = 255;
red = [158 1 66];
orange = [255 164 0];

%% SETUP: DATA and Subject INFO

if ~practice_mode % if not practice mode, save the data
    
    [fname, ~, SID, SessID] = subjectinfo_check(savedir, 'word'); % subfunction
    
    if exist(fname, 'file'), load(fname, 'out'); end
    
    % add some task information
    out.version = 'FAST_fmri_wordgeneration_v1_11-16-2017';
    out.github = 'https://github.com/ByeolEtoileKim/fast_fmri_v1';
    out.subject = SID;
    out.session = SessID;
    out.wordfile = fullfile(savedir, ['a_worddata_sub' SID '_sess' SessID '.mat']);
    out.responsefile = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);
    out.taskfile = fullfile(savedir, ['c_taskdata_sub' SID '_sess' SessID '.mat']);
    out.surveyfile = fullfile(savedir, ['d_surveydata_sub' SID '.mat']);
    out.restingfile = fullfile(savedir, ['e_restingdata_sub' SID '_sess' SessID '.mat']);
    out.exp_starttime = datestr(clock, 0); % date-time: timestamp
    out.seed = seed; % date-time: timestamp
    
    response = cell(41,1); % preallocate the cell structure
    response{1} = out.seed;
    
    % initial save the data
    save(out.wordfile, 'out');
    save(out.responsefile, 'response');
    
end

%% SETUP: Eyelink
theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
    
% need to be revised when the eyelink is here.
if USE_EYELINK
    edf_filename = ['YWG_' SID '_' SessID]; % name should be equal or less than 8
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
    %% START: Screen
	Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
    Screen('TextFont', theWindow, font);
    Screen('TextSize', theWindow, fontsize);
    HideCursor;
    
    %% PROMPT SETUP:
    practice_prompt{1} = double('녹음 테스트를 해보겠습니다.');
    practice_prompt{2} = double('단어가 보이고 벨이 울리면 말씀해주세요. 3번 반복됩니다.');
    practice_prompt{3} = double('\n준비되셨으면 버튼을 눌러주세요.');
    intro_prompt{1} = double('지금부터 말하기 과제를 시작하겠습니다.');
    intro_prompt{2} = double('2.5초마다 벨이 울리면 바로 떠오르는 단어나 문장을 말씀해주세요.');
    intro_prompt{3} = double('떠오르지 않을 경우 전에 말한 내용을 반복해서 말할 수 있습니다.');
    intro_prompt{4} = double('말을 할 때에는 또박또박 말씀해주세요');
    intro_prompt{6} = double('실험자는 모든 것이 잘 준비되었는지 체크해주세요 (Biopac, Eyelink, 등등).\n\n모두 준비되었으면, 스페이스바를 눌러주세요.');
    
    ready_prompt = double('참가자가 준비되었으면, 이미징을 시작합니다 (s).');
    run_end_prompt = double('잘하셨습니다. 잠시 대기해 주세요.');
    
    if practice_mode 
        response_repeat = 5;
    end
    
    %% TEST RECORDING... and play
   
        % Recording Setting
        InitializePsychSound;
        pahandle = PsychPortAudio('Open', [], 2, 0, 44100, 2);
        % Sound recording: Preallocate an internal audio recording  buffer with a capacity of 10 seconds
        PsychPortAudio('GetAudioData', pahandle, 10);
        
        while (1)
            [~,~,keyCode] = KbCheck;
            [~, ~, button] = GetMouse(theWindow);
            if button(1)
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
        
        % Showing seed word, beeping, recording X 3 times
        for n = 1:3
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
            out.test_audiodata{n} = PsychPortAudio('GetAudioData', pahandle);
        end
        
        Screen('FillRect', theWindow, bgcolor, window_rect);
        Screen('TextSize', theWindow, fontsize); % emphasize
        DrawFormattedText(theWindow, run_end_prompt,'center', textH, white);
        Screen('Flip', theWindow);
        
        PsychPortAudio('Close', pahandle);
        save(out.wordfile, 'out');
        
        dat_file = fullfile(savedir, ['a_worddata_sub' SID '_sess' SessID '.mat']);
        load(dat_file);
        
        Screen('FillRect', theWindow, bgcolor, window_rect);
        Screen('TextSize', theWindow, fontsize); % emphasize
        DrawFormattedText(theWindow, run_end_prompt,'center', textH, white);
        Screen('Flip', theWindow);
        
        % play the 3 sounds
        for z=1:3
            WaitSecs(0.5);
            players = audioplayer(out.test_audiodata{z}', 44100);
            play(players);
            WaitSecs(3);
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
            DrawFormattedText(theWindow, intro_prompt{i},'center', textH-40*(2-i), white);
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
    out.runscan_starttime = GetSecs; % run start timestamp
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, double('시작합니다...'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(out.runscan_starttime, 4);
    
    % 4 seconds: Blank
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
        
    %% EYELINK AND BIOPAC START
    
    if USE_EYELINK
        Eyelink('StartRecording');
        out.eyetracker_starttime = GetSecs; % eyelink timestamp
        Eyelink('Message','WG Run start');
    end
        
    if USE_BIOPAC
        out.biopac_starttime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(GetSecs, 1);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    %% SOUND RECORDING INIT
%     InitializePsychSound; % it's saved in run_FAST_fmri_main.m because it
                            % should be run only once for the entire scan.
                            % Maybe, with windows, we can have this here.
                            
    pahandle = PsychPortAudio('Open', [], 2, 0, 44100, 2);
    % Sound recording: Preallocate an internal audio recording  buffer with a capacity of 10 seconds
    PsychPortAudio('GetAudioData', pahandle, 10);
    
    % 10 seconds from the runstart
    waitsec_fromstarttime(out.runscan_starttime, 10);
    
    
    %% MAIN PART of the experiment
    
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, '+','center', textH, white);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(out.runscan_starttime, 11);
    
    out.seedword_starttime = GetSecs; % seed word timestamp
    time_fromstart = 5:2.5:102.5;
    
    % Showing seed word, beeping, recording
    for response_n = 1:response_repeat
        
        % seed word for 2.5s
        if response_n == 1
            Screen('FillRect', theWindow, bgcolor, window_rect);
            Screen('TextSize', theWindow, fontsize*2); % emphasize
            DrawFormattedText(theWindow, double(seed),'center', textH, orange);
            Screen('Flip', theWindow);
            waitsec_fromstarttime(out.seedword_starttime, 2.5);
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
        out.beeptime_from_start(response_n,1) = GetSecs-out.seedword_starttime;
        
        % cross for 1s
        Screen('FillRect', theWindow, bgcolor, window_rect);
        Screen('TextSize', theWindow, fontsize*1.2); % emphasize
        DrawFormattedText(theWindow, '+', 'center', textH, white);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(out.seedword_starttime, time_fromstart(response_n)-1.5)
        
        % blank for 1.5s
        Screen('FillRect', theWindow, bgcolor, window_rect);
        Screen('Flip', theWindow);
        waitsec_fromstarttime(out.seedword_starttime, time_fromstart(response_n))
        
        % stop recording
        PsychPortAudio('Stop', pahandle);
        out.audiodata{response_n} = PsychPortAudio('GetAudioData', pahandle);
        if USE_EYELINK
            Eyelink('Message','WG Trial end');
        end

    end
    if USE_EYELINK
        Eyelink('Message','WG Run end');
        eyelink_main(edfFile, 'Shutdown');       
    end
    
    %% RUN END MESSAGE
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        DrawFormattedText(theWindow, run_end_prompt, 'center', textH, white);
        Screen('Flip', theWindow);
        
        % if not practice mode, save the data
        if ~practice_mode
            out.response{1} = seed;
            save(out.wordfile, 'out');
        end
        
    %% Close the audio device:
    
    PsychPortAudio('Close', pahandle);
    
    if ~practice_mode && savewav 
        [wavedir, wavefname] = fileparts(fname);
        wave_savename = fullfile(wavedir, [wavefname '.wav']);
        audiowrite(wave_savename,cat(2,out.audiodata{:})',44100);
    end
    
    % close screen
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