function grating = generateGrating(sz, sfreq, phase0, theta, dc, contrast)
% This function generate grating based on these parameters:
%   - sfreq: spatial frequency, in pixel
%   - phase0: initial phase of grating, in rad
%   - theta: angle of counterclockwise rotation, in rad (0 for vertical)
%   - dc: duty cycle. The larger the duty cycle, the sparser the grating
%   - contrast: normalized contrast
%   - sz: [x, y], size of screen (or window) to plot, in pixel

xlen = sz(1); % width
ylen = sz(2); % height

[x, y] = meshgrid(1:xlen, 1:ylen);

% move to center
x = x - xlen / 2;
y = y - ylen / 2;

% rotate
x = x * cos(theta) - y * sin(theta); % 旋转后的X坐标
y = x * sin(theta) + y * cos(theta); % 旋转后的Y坐标

grating = sin(2 * pi * sfreq * x + phase0);
grating = contrast * (grating > cos(pi * dc));

return;
end