%%
bgcolor = 100;
window_rect = get(0, 'MonitorPositions'); % full screen
if size(window_rect,1)>1
        window_rect = window_rect(1,:);
end
W = window_rect(3); %width of screen
H = window_rect(4); %height of screen
Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
font = 'NanumBarunGothic';
white = 255;
    
theWindow = Screen('OpenWindow', 0, bgcolor, window_rect);
Screen('TextFont', theWindow, font);

Screen('TextSize', theWindow, 30);
[response_W(1), response_H(1)] = Screen(theWindow, 'DrawText', double('아 그리운 풀밭이'), 0, 0);

Screen('TextSize', theWindow, 50);
[response_W(2), response_H(2)] = Screen(theWindow, 'DrawText', double('좋다'), 0, 0);

interval = 100;

x(1) = W/2 - interval/2 - response_W(1);
x(2) = W/2 + interval/2;

y(1) = H/2 - response_H(1);
y(2) = H/2 - response_H(2);

Screen(theWindow,'FillRect',bgcolor, window_rect);

Screen('TextSize', theWindow, 30);
DrawFormattedText(theWindow, double('아 그리운 풀밭이'), x(1), y(1), white, [], [], [], 1.5);

Screen('TextSize', theWindow, 50);
DrawFormattedText(theWindow, double('좋다'), x(2), y(2), white, [], [], [], 1.5);

Screen('Flip', theWindow);

KbWait;
Screen('CloseAll');
