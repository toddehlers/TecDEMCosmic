function[x2, y2]= map2pix(R,x,y)
fprintf('map2pix: before x: %f, y: %f\n', x, y);

imgX = R(3,1);
imgY = R(3,2);
imgStepX = R(2,1);
imgStepY = R(1,2);

fprintf('imgX: %f, imgY: %f\n', imgX, imgY);
fprintf('imgStepX: %f, imgStepY: %f\n', imgStepX, imgStepY);

x2 = (x - imgX) / imgStepX;
y2 = (y - imgY) / imgStepY;

fprintf('map2pix: after x2: %f, y2: %f\n', x2, y2);

if (x2 < 0.0)
    fprintf('\n\n\nX is negative: %f! Check bounding box!\n', x2);
    if imgStepX > 0.0
        fprintf('X must be > %f!\n', imgX);
    else
        fprintf('X must be < %f!\n', imgX);
    end
    error('Bounding box error!')
end

if (y2 < 0.0)
    fprintf('\n\n\nY is negative: %f! Check bounding box!\n', y2);
    if imgStepY < 0.0
        fprintf('Y must be > %f!\n', imgY);
    else
        fprintf('Y must be < %f!\n', imgY);
    end
    error('Bounding box error!')
end
