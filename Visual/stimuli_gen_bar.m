ccc;
subjectID = 01;   %  TO DO
SAVEPATH = pwd;
pID = 181;
%%
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
dataPath = fullfile(SAVEPATH, [datestr(now, 'yyyymmdd'), '-', num2str(subjectID)]);
mkdir(dataPath);
%% 实验参数结构体
params = struct();
params.screenNum = max(Screen('Screens'));
params.duration = 0.5;          % 刺激持续时间 (sec)
params.changeDuration = 0.02; % 变化持续时间 (sec)
params.barWidthRatio = 1/200;  % 柱子宽度占屏幕比例
params.barHeightRatio = 1/2;  % 柱子高度占屏幕比例
params.moveRange = [0.4 0.6]; % 移动范围比例 [起始 结束]

params.backgroundColor = 1;
params.barColor = [0 0 0];    % 柱子默认颜色
params.changeColor = [0.5 0.5 0.5]; % 变化后颜色
params.responseWindow = 2;    % 行为反应窗口 (sec)
params.ITI = [3, 3.5];        % 试次间隔范围 (sec)

params.staticDisplayFrames = 72; % 静态显示帧数
%% 试次参数
params.changePositions = [0.05, 0.1, 0.15, 0.25, 0.5, 0.75, 0.85, 0.9, 0.95];  % 变化时间点（比例, center）
params.nTrialsPerCondition = 2;         % 每种条件试次数   TO DO
params.validKeys = [37 39];              % 左/右箭头键

%% 初始化窗口
[window, windowRect] = PsychImaging('OpenWindow', params.screenNum, params.backgroundColor);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
barWidthPixels = round(screenXpixels * params.barWidthRatio); % 计算柱子宽度所占像素

totalDistance = screenXpixels * (params.moveRange(2) - params.moveRange(1));  % 柱子中心移动过程所需像素总值
totalFrames = round(params.duration / ifi);  % 要求时长下所需的总帧数
halfChagneFrames = round(params.changeDuration / ifi /2);  % 要求变化时长下所需的帧数的一半
params.pixelsPerFrame = totalDistance / totalFrames; % 每帧移动的像素数
staticDisplayDuration = params.staticDisplayFrames * ifi; % 精确计算静态显示时长
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
    % 计算变化时间窗口(基于正式移动阶段)
    if currentPos
        changeCenterFrame = round(currentPos * totalFrames);
        changeStartFrame = changeCenterFrame - halfChagneFrames;
        changeEndFrame = changeCenterFrame + halfChagneFrames;
    else
        changeStartFrame = inf;
        changeEndFrame = -inf;
    end

    %% 呈现柱子(分静态和移动两个阶段)
    if trialIdx == 1
        tStart = GetSecs - params.ITI(1);  %
    end
    % 第一阶段：静态显示
    leftposition = round(screenXpixels * params.moveRange(1)) - round(barWidthPixels/2); % 初始位置
    barImg = generateBar([screenXpixels, screenYpixels],...
        leftposition, params.barColor,...
        params.barWidthRatio, params.barHeightRatio);
    tex = Screen('MakeTexture', window, barImg);
    tStaticStart = Screen('Flip', window, tStart + params.ITI(1) + rand(1) * diff(params.ITI));
    for frame = 1:params.staticDisplayFrames
        Screen('DrawTexture', window, tex);
        Screen('Flip', window, tStaticStart + (frame-1)*ifi - 0.5*ifi);
    end
    Screen('Close', tex);
    % 第二阶段：开始移动
    tMoveStart = tStaticStart + staticDisplayDuration; % 精确计算移动开始时间
    tRefresh = tMoveStart;
    moveFrameCount = 0; % 移动阶段帧计数器

    while moveFrameCount < totalFrames
        % 计算当前postion
        position = round(screenXpixels * params.moveRange(1) + moveFrameCount * params.pixelsPerFrame);
        leftposition = position - round(barWidthPixels/2);

        % 确定当前color
        if currentPos && moveFrameCount >= changeStartFrame && moveFrameCount <= changeEndFrame
            currentColor = params.changeColor;
        else
            currentColor = params.barColor;
        end

        % 生成
        barImg = generateBar([screenXpixels, screenYpixels],...
            leftposition, currentColor, ...
            params.barWidthRatio, params.barHeightRatio);

        % 呈现刺激
        tex = Screen('MakeTexture', window, barImg);
        Screen('DrawTexture', window, tex);
        tRefresh = Screen('Flip', window, tRefresh + 0.5 * ifi);
        Screen('Close', tex);
        moveFrameCount = moveFrameCount + 1; % 更新移动帧计数
    end

    %% 反应收集阶段
    Screen('FillRect', window, params.backgroundColor);
    tStart = Screen('Flip', window, tRefresh + 0.5 * ifi);

    [respTime, keyPressed] = KbGet([params.validKeys, 27], params.responseWindow);
    if keyPressed == 27 % Esc
        break;
    end

    %% 记录数据
    trialsData(trialIdx).onset = tMoveStart;
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
