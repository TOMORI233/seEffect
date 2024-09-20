%% Tone burst
ccc;

%% 
fs = 48e3;
f = [2e3, 4e3];
ICIs = [4, 4];
dur = 1;
dt = 3e-3;
rfTime = 1e-3;
amp = 0.5;

%% 
t = 1/fs:1/fs:dt;

%% 
y0 = cell(length(ICIs), 1);
for index = 1:length(ICIs)
    nPeriod = fix(ICIs(index) / 1000 * fs);
    temp = amp * sin(2 * pi * f(index) * t);
    temp = genRiseFallEdge(temp, fs, rfTime, "both");
    temp = [temp, zeros(1, nPeriod - length(temp))];
    y0{index} = repmat(temp, [1, ceil(dur / ICIs(index) * 1000)]);
end

%%
figure("WindowState", "maximized");
subplot(2, 1, 1);
plot(y0{1});
subplot(2, 1, 2);
plot(y0{2});
scaleAxes("y", [-1, 1]);

playAudio(y0{1}, fs)