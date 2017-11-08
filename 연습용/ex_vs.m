bgcolor = 100;

window_rect = [1 1 1280 800]
% window_rect = get(0, 'MonitorPositions'); % full screen
if size(window_rect,1)>1
        window_rect = window_rect(1,:);
end

W = window_rect(3); %width of screen
H = window_rect(4); %height of screen

font = 'NanumBarunGothic'; 
fontsize = 30;

white = 255;
red = [189 0 38];
blue = [0 85 169];

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

theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
    Screen('Preference','TextEncodingLocale','ko_KR.UTF-8');
    HideCursor;
    Screen('TextFont', theWindow, font); % setting font
    Screen('TextSize', theWindow, fontsize);

   
%%
xcenter = (lb+rb)/2; %=W/2
ycenter = bb;
xy = [lb xcenter xcenter xcenter rb xcenter xcenter xcenter; 
      ycenter ycenter tb ycenter ycenter ycenter bb ycenter];

Screen('TextSize', theWindow, 22);
anchor_W = Screen(theWindow,'DrawText', double('나와 매우 관련'), 0, 0, bgcolor);
        
Screen(theWindow, 'FillRect', bgcolor, window_rect); % reset
        
Screen('DrawLines',theWindow, xy, 3, 255);
Screen(theWindow,'DrawText', double('부정적'), anchor_xl, ycenter-10, 255);
Screen(theWindow,'DrawText', double('긍정적'), anchor_xr, ycenter-10, 255);
        
Screen(theWindow,'DrawText', double('나와 매우 관련'), xcenter-anchor_W/2, anchor_yu, 255);
Screen(theWindow,'DrawText', double('나와 관련 없음'), xcenter-anchor_W/2, anchor_yd, 255);        
Screen('TextSize', theWindow, fontsize);
Screen('Flip', theWindow);

KbWait;
Screen('CloseAll');