% global theWindow W H; % window property
% global white red orange blue bgcolor response_W; % color
% global fontsize window_rect lb rb tb bb anchor_xl anchor_xr anchor_yu anchor_yd scale_H; % rating scale

bgcolor = 100;

window_rect = [1 1 1280 800]; % in the test mode, use a little smaller screen

W = window_rect(3); %width of screen
H = window_rect(4); %height of screen
textH = H/2.3;

font = 'NanumBarunGothic';
fontsize = 30;

white = 255;
red = [189 0 38];
blue = [0 85 169];
orange = [255 164 0];
red_trans = [189 0 38 80];
blue_trans = [0 85 169 80];

% rating scale left and right bounds 1/3 and 2/3
lb = 1.5*W/5; % in 1280, it's 384
rb = 3.5*W/5; % in 1280, it's 896 rb-lb = 512

% rating scale upper and bottom bounds 1/4 and 3/4
tb = H/5+100;           % in 800, it's 210
bb = H/2+100;           % in 800, it's 450, bb-tb = 240
scale_H = (bb-tb).*0.15;

anchor_xl = lb-80; % 284
anchor_xr = rb+20; % 916
anchor_yu = tb-40; % 170
anchor_yd = bb+20; % 710

bodymap = imread('imgs/bodymap_bgcolor.jpg');
bodymap = bodymap(:,:,1);
[body_y, body_x] = find(bodymap(:,:,1) == 255);

bodymap([1:10 791:800], :) = [];
bodymap(:, [1:10 1271:1280]) = []; % make the picture smaller
%% PROMPT SETUP:
ready_prompt{1}{1} = double('다음에 주어지는 질문에 솔직하게 대답해주세요.');
ready_prompt{1}{2} = double('앞 단어와 연결되어 있는 맥락을 고려해서 대답해주시면 됩니다.');
ready_prompt{1}{3} = double('준비되셨으면 스페이스바를 눌러주세요.');
ready_prompt2 = double('다음에 주어지는 질문에 솔직하게 대답해주세요.\n앞 단어와 연결되어 있는 맥락을 고려해서 대답해주시면 됩니다.\n준비되셨으면 스페이스바를 눌러주세요.');

question_prompt{1}{1} = double('가로축: 단어에서 느껴지는 감정 (부정-긍정)');
question_prompt{1}{2} = double('세로축: 나와의 관련성 (관련없음-관련많음)');
question_prompt{2}{1} = double('이 단어는 시간적으로 과거-현재-미래의 축에서 어디쯤 위치할까요?');
question_prompt{3}{1} = double('이 단어를 생각할 때, 활동이 ''증가''(빨강:r)되거나 ''감소''(파랑:b)되는 몸의 부위가 어디인가요?');
question_prompt{3}{2} = double('클릭한 채로 움직이면 색칠이 됩니다. 색칠이 끝나면 n을 눌러주세요.');

run_end_prompt = double('잘하셨습니다. 다음 단어 세트를 기다려주세요.');
exp_end_prompt = double('설문을 마치셨습니다. 감사합니다!');

theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
Screen('TextFont', theWindow, font);
Screen('TextSize', theWindow, fontsize);

HideCursor;
for i = 1:numel(response) % the number of seed words
    for j = 1:numel(response{i}) % the number of generated words from a seed word
        response_W{i}{j} = Screen(theWindow, 'DrawText', double(response{i}{j}), 0, 0);
    end
end

seeds_i = 1;
target_i = 3;

%% THIRD question: body map - activate and deactivate
SetMouse(W/2, H/2); % set mouse at the center

start_t = GetSecs;

% default
z = randperm(2);
if z(1)==1
    color = red;
    color_code = 1;
else
    color = blue;
    color_code = 2;
end

while(1)

    % draw scale:
    Screen(theWindow, 'FillRect', bgcolor, window_rect); % reset
    Screen('PutImage', theWindow, bodymap); % put bodymap image on screen
    
    % display target word and previous words
    display_target_word(seeds_i, target_i, response);
    

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
    
    % current location
    Screen('DrawDots', theWindow, [x;y], 5, color, [0 0], 1);
    Screen('Flip', theWindow);
    
end 


%%
KbWait;
Screen('CloseAll');

%%
function display_target_word(seeds_i, target_i, response)

global orange theWindow response_W W;

interval = 80;
y_loc = 80;

% ==== DISPLAY 2-3 RESPONSE WORDS ====

% 1. target word
target_loc = W/2 + interval/2;
Screen('TextSize', theWindow, 40); % present word, fontsize = 40
DrawFormattedText(theWindow, double(response{seeds_i}{target_i}), target_loc, y_loc, orange, [], [], [], 1.5);

% 2. Previous word
if target_i > 1
    pre_target_loc = W/2 - interval/2 - response_W{seeds_i}{target_i-1};
    Screen('TextSize', theWindow, 25); % previous word, fontsize = 25
    DrawFormattedText(theWindow, double(response{seeds_i}{target_i-1}), pre_target_loc, y_loc, 180, [], [], [], 1.5);
end


end