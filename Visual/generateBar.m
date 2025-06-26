function barImg = generateBar(screenSize, position, color, widthRatio, heightRatio)
    % 计算实际像素尺寸
    barWidth = round(screenSize(1) * widthRatio);
    barHeight = round(screenSize(2) * heightRatio);
    
    % 创建全白背景图像
    barImg = ones(screenSize(2), screenSize(1), 3); % 1 = 白色
    
    % 计算柱子位置(垂直居中)
    yPos = round((screenSize(2) - barHeight)/2);
    xPos = round(position);
    
    % 确保不超出屏幕边界
    xEnd = min(xPos + barWidth - 1, screenSize(1));
    yEnd = min(yPos + barHeight - 1, screenSize(2));
    
    % 绘制柱子
    barImg(max(1, yPos):yEnd, max(1, xPos):xEnd, :) = ...
        repmat(reshape(color, [1 1 3]), [yEnd-yPos+1, xEnd-xPos+1, 1]);
end
