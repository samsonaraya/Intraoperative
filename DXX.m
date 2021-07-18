function D = DXX(XX,x,y)


cord = sum(y>= XX);

x1 = x(cord);
x2 = x(cord+1);

y1 = y(cord);
y2 = y(cord+1);

Prop = (XX-y2)/(y1-y2);


D = x1 + Prop*(x2-x1);