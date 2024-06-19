%% start-end effect
ccc;

ord = char([48:57, 65:90, 97:122]'); % [0-9, A-Z, a-z]'

rfTime = 5e-3;
silenceTime = 10e-3;
noiseDur = 20e-3;
interval = 500e-3;

% Tone
fs = 48e3;
dur = 0.5;
t = 0:1 / fs:dur;

% f = 4e3;
% SNRs = 26:2:40; % dB, for 4k

f = 1e3;
% SNRs = [36, 44:2:56]; % dB, for 1k
SNRs = 52;

% f = 200;
% SNRs = 40:2:54; % dB, for 200

y_silence = zeros(1, fix(silenceTime * fs));
y0 = 0.5 * sin(2 * pi * f * t);
y0 = [y_silence, genRiseFallEdge(y0, fs, rfTime, "both"), y_silence];

audiowrite(['sounds\', ord(1), '_', num2str(f), '_NAN_SNRinf.wav'], [y0, zeros(1, fix(interval * fs)), y0], fs);

%% 
N_Total = length(y0);
% Ns = fix([1, 2.5, 4] * N_Total / 5);
Ns = fix((1:7) * N_Total / 8);

for index1 = 1:length(Ns)
    N = Ns(index1) - fix(noiseDur * fs / 2);
    
    for index2 = 1:length(SNRs)
        y_noise = awgn(y0, SNRs(index2));
        
        y1 = [y0(1:N - 1), y_noise(N:N + fix(noiseDur * fs) - 1), y0(N + fix(noiseDur * fs):end)];
        yF = [y0, zeros(1, fix(interval * fs)), y1];
        
        audiowrite(['sounds\', ord(1 + (index1 - 1) * length(SNRs) + index2), '_', num2str(f), '_', num2str(N), '_SNR', num2str(SNRs(index2)), '.wav'], yF, fs);
    end
    
    % forward
    figure;
    subplot(2, 1, 1);
    plot(y0);
    subplot(2, 1, 2);
    plot(y1);
    hold on;
    plot(N:N + fix(noiseDur * fs) - 1, y_noise(N:N + fix(noiseDur * fs) - 1), 'r.');
end