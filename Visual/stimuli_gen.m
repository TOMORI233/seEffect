ccc;
%% 
speed = pi/4;
dur = 1;
spatialFreq = 0.01; % 空间频率（周期/像素）
contrast = 1.0; % 对比度（0到1）
phase = 0; % 相位
theta = pi/360;
dutyCycle = 0.6;
t_start = 0.45;
t_end = 0.65;

%%
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
screenNumber = max(Screen('Screens'));
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 128);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);

% TODO: for-loop
grating = generateGrating([screenXpixels, screenYpixels], spatialFreq, phase, 0, dutyCycle, contrast);
gratingTexture = Screen('MakeTexture', window, grating);
Screen('DrawTexture', window, gratingTexture);
t0 = Screen('Flip', window);
t = t0;

while t <= t0 + dur
    phase = phase + speed;

    if t >= t0 + t_start && t <= t0 + t_end
        grating = generateGrating([screenXpixels, screenYpixels], spatialFreq, phase, theta, dutyCycle, contrast);
        gratingTexture = Screen('MakeTexture', window, grating);
        Screen('DrawTexture', window, gratingTexture);
        t = Screen('Flip', window, t + 0.5 * ifi);
        continue;
    end

    grating = generateGrating([screenXpixels, screenYpixels], spatialFreq, phase, 0, dutyCycle, contrast);
    gratingTexture = Screen('MakeTexture', window, grating);
    Screen('DrawTexture', window, gratingTexture);
    t = Screen('Flip', window, t + 0.5 * ifi);
end
temp = Screen('MakeTexture', window, ones(windowRect(4), windowRect(3)));
Screen('DrawTexture', window, temp);
t = Screen('Flip', window, t + 0.5 * ifi);

% % temp = Screen('MakeTexture', window, ones(windowRect(4), windowRect(3)));
% Screen('DrawPoint',window, temp);
% t = Screen('Flip', window, t + 0.5 * ifi);

pressTime = KbGet([37, 39], inf);
sca;