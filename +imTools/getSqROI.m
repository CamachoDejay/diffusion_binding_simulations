function [sqIm, idx] = getSqROI(im)
%GETSQROI Summary of this function goes here
%   Detailed explanation goes here
f = figure();
imagesc(im)
axis image
colormap('gray')
title('Please select a squared area')

rect = getrect;
rect = round(rect);
xi = rect(2);
xf = xi + rect(4);
yi = rect(1);
yf = yi + rect(3);
idx.row = xi:xf;
idx.col = yi:yf;
sqIm = im(idx.row, idx.col);
close(f)
end

