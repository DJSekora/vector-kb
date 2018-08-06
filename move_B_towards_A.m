function [outvec] =  move_B_towards_A(vec1,vec2,fraction)
outvec=vec2-fraction*(vec2-vec1);