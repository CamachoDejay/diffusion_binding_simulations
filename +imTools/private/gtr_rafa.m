function [ Int, BG, C ] = gtr_rafa( mov, emi, bgi )
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here
    im_size = [size(mov,1), size(mov,2)];
    
    [emX,emY] = ind2sub(im_size, emi);
    [bgX,bgY] = ind2sub(im_size, bgi);
    C(:) = [mean(emY), mean(emX)];
    
    tmp = uint16(zeros(size(mov,3),size(emY,1)));
    for j = 1:size(emY,1)
        tmp(:,j) = mov(emX(j),emY(j),:);        
    end
    Int(:) = mean(tmp,2);
    
    tmp = uint16(zeros(size(mov,3),size(bgY,1)));
    for j = 1:size(bgY,1)
        tmp(:,j) = mov(bgX(j),bgY(j),:);        
    end
    BG(:) = mean(tmp,2);
    
end

