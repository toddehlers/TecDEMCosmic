function [x,y] = pix2map(R,col,row)


t = [row col] * R(1:2,:);
x = t(:,1) + R(3,1);
y = t(:,2) + R(3,2);
