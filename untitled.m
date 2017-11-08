
bodymap = imread('imgs/bodymap_bgcolor.jpg');
bodymap = bodymap(:,:,1);
[body_y, body_x] = find(bodymap(:,:,1) == 255);

bodymap([1:10 791:800], :) = [];
bodymap(:, [1:10 1271:1280]) = []; % make the picture smaller


bgcolor = 100;

window_rect = [1 1 1980 1080]; % in the test mode, use a little smaller screen

W = window_rect(3); %width of screen
H = window_rect(4); %height of screen
textH = H/2.3;


theWindow = Screen('OpenWindow', 0, bgcolor, window_rect); % start the screen
HideCursor;


Screen(theWindow, 'FillRect', bgcolor, window_rect);
Screen('PutImage', theWindow, bodymap, window_rect); % put bodymap image on screen
Screen('Flip', theWindow);

KbWait;
Screen('CloseAll');
