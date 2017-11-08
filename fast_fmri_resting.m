function rest = fast_fmri_word_generation(seed, varargin)

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
            case {'test', 'testmode'}
                testmode = true;
        end
    end
end

%% SETUP: global
global theWindow W H; % window property
global white red orange bgcolor; % color
global window_rect; % rating scale

%% SETUP: Screen

addpath(genpath(psychtoolboxdir));

bgcolor = 100;

if testmode
    window_rect = [1 1 1280 800]; % in the test mode, use a little smaller screen
else
    window_rect = get(0, 'MonitorPositions'); % full screen
    if size(window_rect,1)>1   % for Byeol's desk, when there are two moniter
        window_rect = window_rect(1,:);
    end
end

W = window_rect(3); % width of screen
H = window_rect(4); % height of screen
textH = H/2.3;


font = 'NanumBarunGothic';
fontsize = 30;

%% SETUP: DATA and Subject INFO
   
    [fname, ~, SID, SessID] = subjectinfo_check(savedir, 'resting'); % subfunction
      
    % add some task information
    rest.version = 'FAST_fmri_wordgeneration_v1_11-05-2017';
    rest.github = 'https://github.com/ByeolEtoileKim/fast_fmri_v1';
    rest.subject = SID;
    rest.session = SessID;
    rest.wordfile = fullfile(savedir, ['a_worddata_sub' SID '_sess' SessID '.mat']);
    rest.responsefile = fullfile(savedir, ['b_responsedata_sub' SID '_sess' SessID '.mat']);
    rest.taskfile = fullfile(savedir, ['c_taskdata_sub' SID '_sess' SessID '.mat']);
    rest.surveyfile = fullfile(savedir, ['d_surveydata_sub' SID '_sess' SessID '.mat']);
    rest.resting = fullfile(savedir, ['e_restingdata_sub' SID '.mat']);    
    rest.exp_starttime = datestr(clock, 0); % date-time: timestamp
    
    rest.data = cell(1, 6);
  
    % initial save the data
    save(rest.data{SessID}, 'rest');

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
    intro_prompt{1} = double('이제 6분간 쉬는 동안의 뇌 활동을 찍는 과제를 하겠습니다.');
    intro_prompt{2} = double('이 과제에서는 눈은 자연스럽게 떠 주시고 화면을 바라봐 주세요.');
    intro_prompt{3} = double('시작하시려면 버튼을 눌러주세요.');
    intro_prompt{4} = double('이제 2분간 쉬는 동안의 뇌 활동을 찍는 과제를 하겠습니다.');

    ready_prompt = double('참가자가 준비되었으면, 이미징을 시작합니다 (s).');
    
    run_end_prompt = double('잘하셨습니다. 잠시 대기해 주세요.');
    
    
    %% TEST RECORDING... and play
    
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
        WaitSecs(.3)
           
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
    waitsec_fromstarttime(rest.runscan_starttime, 4);
    
    % 4 seconds: Blank
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    DrawFormattedText(theWindow, double('+'), 'center', 'center', white, [], [], [], 1.2);
    Screen('Flip', theWindow);
        
    %% EYELINK AND BIOPAC SETUP
    
    if USE_EYELINK
        Eyelink('StartRecording');
        rest.eyetracker_starttime = GetSecs; % eyelink timestamp
    end
        
    if USE_BIOPAC
        rest.biopac_starttime = GetSecs; % biopac timestamp
        BIOPAC_trigger(ljHandle, biopac_channel, 'on');
        waitsec_fromstarttime(rest.biopac_starttime, 1);
        BIOPAC_trigger(ljHandle, biopac_channel, 'off');
    end
    
    %% MAIN PART of the experiment
    
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    DrawFormattedText(theWindow, '+','center', textH, white);
    Screen('Flip', theWindow);
    waitsec_fromstarttime(rest.runscan_starttime, 11);
    
    rest.seedword_starttime = GetSecs; % seed word timestamp
    
    % Showing seed word, beeping, recording
    for response_n = 1:response_repeat
        
        % seed word for 2.5s
        if response_n == 1
            
            Screen('FillRect', theWindow, bgcolor, window_rect);
            Screen('TextSize', theWindow, fontsize*1.2); % emphasize
            DrawFormattedText(theWindow, double(seed),'center', textH, orange);
            Screen('Flip', theWindow);
%             Screen('TextSize', theWindow, fontsize);   %****없어도 되는듯
            waitsec_fromstarttime(rest.seedword_starttime, 2.5);
            
        end
        

    end
    
    %% RUN END MESSAGE
        Screen(theWindow, 'FillRect', bgcolor, window_rect);
        DrawFormattedText(theWindow, run_end_prompt, 'center', textH, white);
        Screen('Flip', theWindow);
        
        % if not practice mode, save the data
        if ~practice_mode
            rest.response{1} = seed;
            save(rest.wordfile, 'out');
        end
        
    %% Close the audio device:
    
    PsychPortAudio('Close', pahandle);
    
    if ~practice_mode && savewav 
        [wavedir, wavefname] = fileparts(fname);
        wave_savename = fullfile(wavedir, [wavefname '.wav']);
        audiowrite(wave_savename,cat(2,rest.audiodata{:})',44100);
    end
        
    
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