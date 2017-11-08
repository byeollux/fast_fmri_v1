
%% SETUP: global
global theWindow W H; % window property
global white red orange blue bgcolor ; % color
global fontsize window_rect lb tb bodymap recsize barsize rec words; % rating scale

%% SETUP: Screen
words = {'»ç¶û'    '»ç¶û'    'È¯»ó'    '¾ÆÇÄ'    'ÇÐ´ë';
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
    lb,tb+2*recsize(2); lb+recsize(1),tb+2*recsize(2)]; %6°³ »ç°¢ÇüÀÇ ¿ÞÂÊ À§ ²ÀÁþÁ¡ÀÇ ÁÂÇ¥


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


%% Survey start: ========================================================    
    
z = randperm(6);
barsize = barsize(:,z);
seeds_i=3;
target_i=1;
    
    %% Receive response
    
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
    
    
    KbWait;
    Screen('CloseAll');



