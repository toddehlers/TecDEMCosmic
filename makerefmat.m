function R = makerefmat(x11,y11,dx,dy)

dx = [0 dx];
dy = [dy 0];

W = [dx(2) dx(1) x11;...
     dy(2) dy(1) y11];

C = [0  1  -1;...
     1  0  -1;...
     0  0   1];

R = (W * C)';