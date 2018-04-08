%% default setting
testmode = false;
savedir = fullfile(pwd, 'data');
response_repeat = 40;
out = [];
addpath(genpath(pwd));

%% SETUP: global
global theWindow W H; % window property
global white red orange bgcolor; % color
global window_rect; % rating scale

%% SETUP: Screen

bgcolor = 100;

% these 5 lines are from CAPS. In case of fMRI+ThinkPad+full
% screen, these are nessecary and different from Wani's version.
screens = Screen('Screens');
window_num = screens(1);
Screen('Preference', 'SkipSyncTests', 1);
window_info = Screen('Resolution', window_num);
window_rect = [0 0 window_info.width window_info.height]; %0 0 1920 1080

W = window_rect(3); % width of screen
H = window_rect(4); % height of screen
textH = H/2.3;

font = 'NanumGothic';
fontsize = 30;

white = 255;
red = [158 1 66];
orange = [255 164 0];


%% START: Screen
theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
Screen('TextFont', theWindow, font);
Screen('TextSize', theWindow, fontsize);
HideCursor;

%% TAST START: ===========================================================

try
    %% PROMPT SETUP:
    intro_prompt{1} = double('지금부터 말하기 과제를 시작하겠습니다.');
    intro_prompt{2} = double('2.5초마다 벨이 울리면 바로 떠오르는 단어나 문장을 말씀해주세요.');
    intro_prompt{3} = double('떠오르지 않을 경우 전에 말한 내용을 반복해서 말할 수 있습니다.');
    intro_prompt{4} = double('시작하려면 클릭해주세요.');
    
    exseed = {'봄바람', '수원'};
    rating_prompt = double('정서 단어를 기억하려고 해보세요.');
    run_end_prompt = double('잘하셨습니다.');
    
    %% TASK
    for s = 1:2
        while (1)
            [~,~,keyCode] = KbCheck;
            [~, ~, button] = GetMouse(theWindow);
            if button(1)
                break
            elseif keyCode(KbName('q'))==1
                abort_man;
            end
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            for i = 1:numel(intro_prompt)
                DrawFormattedText(theWindow, intro_prompt{i},'center', textH-50*(2-i), white);
            end
            Screen('Flip', theWindow);
        end
        
        % Showing seed word, beeping X 5 times
        for n = 1:5
            % seed word for 2.5s
            if n == 1
                Screen('FillRect', theWindow, bgcolor, window_rect);
                Screen('TextSize', theWindow, fontsize*2); % emphasize
                DrawFormattedText(theWindow, double(exseed{s}),'center', textH, orange);
                Screen('Flip', theWindow);
                waitsec_fromstarttime(GetSecs, 2.5);
            end
            
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
        end
    end
    
    Screen('FillRect', theWindow, bgcolor, window_rect);
    Screen('TextSize', theWindow, fontsize);
    DrawFormattedText(theWindow, rating_prompt,'center', textH, white);
    Screen('Flip', theWindow);
    WaitSecs(2);
    
    rng('shuffle');        % it prevents pseudo random number
    rand_z = randperm(14); % random seed
    display_emotion_words(rand_z);
    WaitSecs(0.7);
    
    Screen('FillRect', theWindow, bgcolor, window_rect);
    Screen('TextSize', theWindow, fontsize);
    DrawFormattedText(theWindow, run_end_prompt,'center', textH, white);
    Screen('Flip', theWindow);
    WaitSecs(3);
    Screen('CloseAll');
    
catch err
    % ERROR
    disp(err);
    for i = 1:numel(err.stack)
        disp(err.stack(i));
    end
    abort_experiment('error');
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


function display_emotion_words(z)

global W H white theWindow window_rect bgcolor square fontsize orange red

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
colors = 200;

%% words

choice = {'기쁨', '괴로움', '희망', '두려움', '행복', '실망', '자부심', '부끄러움', '후회', '슬픔', '분노', '사랑', '미움', '없음'};
choice = choice(z);

%%
SetMouse(W/2, H/2);

trajectory_time = [];
starttime = GetSecs;

j = 0;

while(1)
    j = j + 1;
    [x, y, button] = GetMouse(theWindow);
    
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
    Screen('DrawDots', theWindow, [x y], 10, orange, [0, 0], 1); % draw orange dot on the cursor
    Screen('Flip', theWindow);
    trajectory_time(j) = GetSecs - starttime; % trajectory of time
    
    
    if trajectory_time(end) >= 10  % maximum time of rating is 10s
        button(1) = true;
    end
    
    if button(1)  % After click, the color of cursor dot changes.
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
        Screen('DrawDots', theWindow, [x;y], 10, red, [0 0], 1);
        Screen('Flip', theWindow);
        WaitSecs(0.3);
        
        break;
    end
    
end
end