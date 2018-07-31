function [ I, B, C, info ] = getTransientsFromMovie( mov, pos, emitter_r, exclusion_r, bg_r )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here

nframe = size(mov,3);
im_size = [size(mov,1), size(mov,2)];
npos    = size(pos,1);

pos = round(pos);

I = zeros(nframe,npos);
B = zeros(nframe,npos);
C = zeros(npos,2);

str_em = strel('disk', emitter_r);
str_ex = strel('disk', exclusion_r);
str_bg = strel('disk', bg_r);

linearInd = sub2ind(im_size, pos(:,1), pos(:,2));
% LI        = linearInd;

BW = false(im_size);
BW(linearInd) = true;
BW_excl = imdilate(BW,str_ex);

for i = 1:npos
    
    BW = false(im_size);
    BW(linearInd(i)) = true;
    BW_em   = imdilate(BW,str_em);
    BW_bg   = imdilate(BW,str_bg);
        
    BW_bg = and(BW_bg,~BW_excl);
        
    emi = find(BW_em);
    bgi = find(BW_bg);

    [ I(:,i), B(:,i), C(i,:) ] = gtr_rafa( mov, emi, bgi );
    
    disp(['Done with molec ' num2str(i)])
    
end

info.particleSize = sum(BW_em(:));
info.bgSize = sum(BW_bg(:));
end

