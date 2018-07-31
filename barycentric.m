function [b] = barycentric(point,simplex)
onesize=size(simplex,1);
top=[point,1];
%top=top+.00000001*rand(size(top));
bottom=[simplex,ones(onesize,1)];
%bottom=bottom+.00000001*rand(size(bottom));
b = top/bottom;
