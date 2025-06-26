params = struct();
params.screenNum = max(Screen('Screens'));
params.backgroundColor = 128;
params.speed = pi/4;          % 相位变化速度 (rad/sec)
params.duration = 1;          % 光栅持续时间 (sec)
params.spatialFreq = 0.01;    % 空间频率 (cycles/pixel)
params.contrast = 1.0;        % 对比度
params.dutyCycle = 0.6;       % 占空比
params.angleChange = pi/720;   % 倾斜角度变化量
params.changeDuration = 0.05;  % 变化持续时间 (sec)
params.responseWindow = 2;    % 反应窗口 (sec)
params.ISI = [2.5 3];           % 试次间隔范围 (sec)
params.nMiss = 0;
%%
theta = 0;
grating = generateGrating([1920, 1200],...
    params.spatialFreq, 0, theta,...
    params.dutyCycle, params.contrast);
subplot(2,1,1)
imagesc(grating);
colormap gray;
theta = pi/360;
grating = generateGrating([1920, 1200],...
    params.spatialFreq, 0, theta,...
    params.dutyCycle, params.contrast);
subplot(2,1,2)
imagesc(grating);
colormap gray;