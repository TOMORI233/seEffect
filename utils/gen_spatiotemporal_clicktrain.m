ccc;

%%
fs = 48e3;
dur = 2;
clickLen = 200e-6;
ICIs = [4, 5]; % ms

%% 
y0 = cell(length(ICIs), 1);
[y0{:}] = deal(zeros(1, fix(dur * fs)));
nPulse = fix(clickLen * fs);
for index = 1:length(ICIs)
    nPeriod = fix(ICIs(index) / 1000 * fs);
    n = 1;
    while n < fix(dur * fs)
        y0{index}(n:n + nPulse - 1) = 1;
        n = n + nPeriod;
    end
end

%% 
y1 = [y0{1}(:), y0{2}(:)];
playAudio(y1, fs);

y2 = double(logical(y0{1} + y0{2}));
playAudio(y2, fs);
plot(y2)
