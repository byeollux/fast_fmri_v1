
%% SETUP: global
global theWindow W H; % window property
global white red orange blue bgcolor ; % color
global fontsize window_rect lb tb bodymap recsize barsize rec words; % rating scale

%% SETUP: Screen
words = {'사랑'    '사랑'    '환상'    '아픔'    '학대';
    '1'       '1'       '1'       '1'       '1'   ;
    '2'       '2'       '2'       '2'       '2'   ;
    '3'       '3'       '3'       '3'       '3'   ;
    '4'       '4'       '4'       '4'       '4'   ;
    '5'       '5'       '5'       '5'       '5'   ;
    '6'       '6'       '6'       '6'       '6'   ;
    '7'       '7'       '7'       '7'       '7'   ;
    '8'       '8'       '8'       '8'       '8'   ;
    '9'       '9'       '9'       '9'       '9'   ;
    '10'      '10'      '10'      '0'       '10'  ;
    '11'      '11'      '11'      '1'       '11'  ;
    '12'      '12'      '1'       '2'       '12'  ;
    '13'      '13'      '3'       '3'       '3'   ;
    '4'       '14'      '4'       '4'       '4'   ;
    '5'       '15'      '5'       '5'       '5'   ;
    '6'       '16'      '6'       '6'       '6'   ;
    '7'       '17'      '7'       '7'       '7'   ;
    '8'       '1819'    '8'       '8'       '8'   ;
    '9'       '19'      '9'       '9'       '9'   ;
    '20'      '20'      '0'       '0'       '0'   ;
    '1'       '21'      '21'      '1'       '1'   ;
    '2'       '22'      '22'      '2'       '2'   ;
    '3'       '2'       '23'      '3'       '3'   ;
    '4'       '24'      '24'      '4'       '4'   ;
    '5'       '25'      '25'      '5'       '5'   ;
    '6'       '26'      '26'      '6'       '6'   ;
    '7'       '27'      '27'      '7'       '7'   ;
    '8'       '28'      '28'      '8'       '8'   ;
    '9'       '29'      '29'      '9'       '9'   ;
    '30'      '30'      '30'      '0'       '0'   ;
    '1'       '1'       '31'      '1'       '1'   ;
    '2'       '32'      '32'      '2'       '2'   ;
    '3'       '33'      '33'      '3'       '3'   ;
    '4'       '34'      '34'      '4'       '4'   ;
    '5'       '35'      '35'      '5'       '5'   ;
    '6'       '36'      '36'      '6'       '6'   ;
    '37'      '7'       '7'       '7'       '7'   ;
    '38'      '8'       '8'       '8'       '8'   ;
    '39'      '9'       '9'       '9'       '9'   ;
    '40'      '402'     '402'     '404'     '405' };
pw = {'고양이';'노랑';'크리스마스';'히비스커스';'음악'};
seeds_i = 1;
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

lb=W*7/128;    % 70 or 120        when W=1280
tb=H*18/80;     % 180

recsize=[W*450/1280 H*175/800];     % W*450 or 520
barsize=[W*340/1280, W*200/1280, W*340/1280, W*200/1280, W*340/1280, 0;
    10, 10, 10, 10, 10, 0; 10, 0, 10, 0, 10, 0;
    10, 10, 10, 10, 10, 0; 1, 2, 3, 4, 5, 0];
rec=[lb,tb; lb+recsize(1),tb; lb,tb+recsize(2); lb+recsize(1),tb+recsize(2);
    lb,tb+2*recsize(2); lb+recsize(1),tb+2*recsize(2)]; %6개 사각형의 왼쪽 위 꼭짓점의 좌표


bodymap = imread('imgs/bodymap_bgcolor.jpg');
bodymap = bodymap(:,:,1);
[body_y, body_x] = find(bodymap(:,:,1) == 255);

bodymap([1:10 791:800], :) = [];
bodymap(:, [1:10 1271:1280]) = []; % make the picture smaller
theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
Screen('TextFont', theWindow, font);
Screen('TextSize', theWindow, fontsize);
HideCursor;

ready_prompt{1} = double('지금부터 스캐너에서 말한 각 단어를 바로 직전에 말한 단어와');
ready_prompt{2} = double('이어지는 맥락을 고려하여 각 질문에 솔직하게 응답해주세요.');
ready_prompt{3} = double('여기서 맥락이란 일반적인 단어 사이의 관계를 의미하는 것이 아니라,');
ready_prompt{4} = double('본인이 그 단어를 떠올렸을 당시에 느꼈던 개인적인 감정 혹은 생각을 의미합니다.');
ready_prompt{5} = double('설문은 총 6개의 세트로 이루어져 있으며 세트가 끝날 때마다 휴식을 취하셔도 좋습니다.');
ready_prompt{6} = double('약 2시간 정도 예상되는 설문이므로 마지막까지 집중해서 응답해주시기를 바랍니다.');
ready_prompt{7} = double('\n시작하려면 스페이스를 눌러주세요.');


%% Survey start: ========================================================
for j = 1:5
    z = randperm(6);
    barsize = barsize(:,z);
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
    %% Receive response
    for target_i = 1:numel(pw)-1 % loop through the response words (5)
        
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
                    display_survey(z, seeds_i, target_i, words,'whole');
                    Screen('DrawDots', theWindow, [x;y], 9, orange, [0 0], 1);
                    Screen('Flip', theWindow);
                    
                    
                    if button(1)
                        display_survey(z, seeds_i, target_i, words,'whole');
                        Screen('DrawDots', theWindow, [x,y], 9, red, [0 0], 1);
                        Screen('Flip', theWindow);
                        
                        WaitSecs(.3);
                        break;
                    end
                end
            end
        end
        WaitSecs(.3);
        
        %% body map
        
        SetMouse(W*8.4/10, H/2); % set mouse at the center of the body
        
        % default
        zc = randperm(2);
        if zc(1)==1
            color = red;
            color_code = 1;
        else
            color = blue;
            color_code = 2;
        end
        
        while(1)
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
    
    
end


% Blank for ITI
Screen(theWindow,'FillRect',bgcolor, window_rect);
Screen('TextSize', theWindow, fontsize);
DrawFormattedText(theWindow, practice_end_prompt, 'center', 'center', white, [], [], [], 1.5);
Screen('Flip', theWindow);
WaitSecs(2);

KbWait;
Screen('CloseAll');



