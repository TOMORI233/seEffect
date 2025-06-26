ccc;
subjectID = 01;   %  TO DO
SAVEPATH = pwd;
pID = 180;
%%
PsychDefaultSetup(2);
% Screen('Preference', 'SkipSyncTests', 1);
dataPath = fullfile(SAVEPATH, [datestr(now, 'yyyymmdd'), '-', num2str(subjectID)]);
mkdir(dataPath);
%% 实验参数结构体
params = struct();
params.screenNum = max(Screen('Screens'));
params.backgroundColor = 128;
params.speed = pi/4;          % 相位变化速度 (rad/sec)
params.duration = 1;          % 光栅持续时间 (sec)
params.spatialFreq = 0.01;    % 空间频率 (cycles/pixel)
params.contrast = 1.0;        % 对比度
params.dutyCycle = 0.6;       % 占空比
params.angleChange = pi/360;  % 倾斜角度变化量
params.changeDuration = 0.05; % 变化持续时间 (sec)
params.responseWindow = 2;    % 反应窗口 (sec)
params.ITI = [3.5, 4];        % 试次间隔范围 (sec)
params.nMiss = 0;
%% 试次参数
params.changePositions = [0.05, 0.1, 0.2, 0.5, 0.8, 0.9, 0.95];  % 变化时间点（比例, center）
params.nTrialsPerCondition = 5;         % 每种条件试次数
params.validKeys = [37 39];              % 左/右箭头键

%% 初始化窗口
[window, windowRect] = PsychImaging('OpenWindow', params.screenNum, params.backgroundColor);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);

%%
startImg = imread('startjpg.jpg');
tex = Screen('MakeTexture', window, startImg);
Screen('DrawTexture', window, tex);
Screen('Flip', window);

KbGet(32, 20);
Screen('FillRect', window, params.backgroundColor);
Screen('Flip', window);

%% 生成试次序列
trialTypes = [0, params.changePositions]; % 0表示无变化
trialOrder = repmat(trialTypes, 1, params.nTrialsPerCondition);
trialOrder = trialOrder(randperm(length(trialOrder)));

%% 数据记录结构
temp = cell(length(trialOrder), 1);
trialsData = struct('onset', temp,...
                    'changePos', num2cell(trialOrder'),...
                    'respTime', temp,...
                    'keyPressed', temp);

%% 实验主循环
for trialIdx = 1:length(trialOrder)
    % 当前试次参数
    currentPos = trialOrder(trialIdx);
    hasChange = currentPos ~= 0;

    % 计算变化时间窗口
    if hasChange
        changeStart = params.duration * currentPos/2;
        changeEnd = changeStart + params.changeDuration;
    else
        changeStart = inf;
        changeEnd = -inf;
    end

    %% 呈现光栅
    if trialIdx == 1
        tStart = GetSecs - 3;
    end

    % 第一帧
    phase = 0; % 重置相位
    grating = generateGrating([screenXpixels, screenYpixels],...
                              params.spatialFreq, phase, 0,...
                              params.dutyCycle, params.contrast);
    tex = Screen('MakeTexture', window, grating);
    Screen('DrawTexture', window, tex);
    tStart = Screen('Flip', window, tStart + params.ITI(1) + rand(1) * diff(params.ITI));
    tRefresh = tStart;

    while GetSecs <= tStart + params.duration
        % 计算当前时间
        elapsed = GetSecs - tStart;

        % 更新相位
        phase = phase + params.speed;

        % 确定当前角度
        if elapsed >= changeStart && elapsed <= changeEnd
            theta = params.angleChange;
        else
            theta = 0;
        end

        % 生成光栅
        grating = generateGrating([screenXpixels, screenYpixels],...
                                  params.spatialFreq, phase, theta,...
                                  params.dutyCycle, params.contrast);

        % 呈现刺激
        tex = Screen('MakeTexture', window, grating);
        Screen('DrawTexture', window, tex);
        tRefresh = Screen('Flip', window, tRefresh + 0.5 * ifi);
    end

    %% 反应收集阶段
    Screen('FillRect', window, params.backgroundColor);
    tResponseStart = Screen('Flip', window, tRefresh + 0.5 * ifi);

    [respTime, keyPressed] = KbGet([params.validKeys, 27], params.responseWindow);
    if keyPressed == 27
        break;
    end

    %% 记录数据
    trialsData(trialIdx).onset = tStart;
    trialsData(trialIdx).changePos = currentPos;
    trialsData(trialIdx).respTime = respTime;
    trialsData(trialIdx).keyPressed = keyPressed;
end
%%
endImg = imread('endjpg.jpg');
tex = Screen('MakeTexture', window, endImg);
Screen('DrawTexture', window, tex);
Screen('Flip', window);
WaitSecs(1);

%% 清理和保存
sca;
ShowCursor;

trialsData(arrayfun(@(x) isempty(x.onset), trialsData)) = [];

if ~exist(fullfile(dataPath, [num2str(pID), '.mat']), 'file')
    save(fullfile(dataPath, [num2str(pID), '.mat']), "trialsData", "params");
else
    save(fullfile(dataPath, [num2str(pID), '_redo.mat']), "trialsData", "params");
end
%%
disp('Experiment completed!');
