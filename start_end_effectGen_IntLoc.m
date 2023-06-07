%% start-end effect
ccc;

ord = arrayfun(@(x) strrep(x, ' ', '0'), num2str((1:100)'));
soundPath = 'D:\Education\Lab\Projects\EEG\EEG App\sounds\2\';

rfTime = 5e-3;
silenceTime = 0;
changeDur = 20e-3;
interval = 500e-3;
Amp = 0.5;

fs = 48e3;
dur = 0.5;
t = 0:1 / fs:dur;

f = 1e3;
intDiff = 0.15;

y_silence = zeros(1, fix(silenceTime * fs));
y0 = Amp * sin(2 * pi * f * t);
y0 = [y_silence, genRiseFallEdge(y0, fs, rfTime, "both"), y_silence];

mkdir(soundPath);
audiowrite([soundPath, ord(1, :), ...
            '_freq-', num2str(f), ...
            '_locN-NAN_Diff-0.wav'], [y0, zeros(1, fix(interval * fs)), y0], fs);

%% 
N_Total = length(y0);
Ns = fix([1, 3, 5, 8, 11, 13, 15] * N_Total / 16);

for index1 = 1:length(Ns)
    N = Ns(index1) - fix(changeDur * fs / 2);
    
    for index2 = 1:length(intDiff)
        y1 = [y0(1:N - 1), (1 + intDiff(index2)) * y0(N:N + fix(changeDur * fs) - 1), y0(N + fix(changeDur * fs):end)];
        yF = [y0, zeros(1, fix(interval * fs)), y1];
        
        audiowrite([soundPath, ord(1 + (index1 - 1) * length(intDiff) + index2, :), ...
                    '_freq-', num2str(f), ...
                    '_locN-', num2str(N), ...
                    '_Diff-', num2str(100 * intDiff(index2)), ...
                    '.wav'], yF, fs);
    end
    
    % forward
    figure;
    subplot(2, 1, 1);
    plot(y0);
    subplot(2, 1, 2);
    plot(y1);
    hold on;
    plot(N:N + fix(changeDur * fs) - 1, y1(N:N + fix(changeDur * fs) - 1), 'r.');
end

rulesGenerator(soundPath, "D:\Education\Lab\Projects\EEG\EEG App\rules\rules.xlsx", 2, ...
               "start-end效应部分", "第二阶段-位置", "active", "SE active2", ...
               3.5, 40);