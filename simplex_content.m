function content=simplex_content(new_simplex)
%note: to actually calculate the content, this result needs to be
%multiplied by a factor of (-1)/((-2)^simplex_size)((simplex_size)!)^2). But if you
%are just comparing simplices of the same size, this can be neglected.
    P=sqdist(new_simplex,new_simplex);
    simplex_size=size(new_simplex,2);
    Phat=ones(simplex_size+1);
    Phat(1,1)=0;
    Phat(2:end,2:end)=P;
    content=abs(det(Phat));
end