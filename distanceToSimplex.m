function [distance, projection] = distanceToSimplex(point,S)
% an implementation of An Algorithm to Compute the Distance from a Point to a Simplex
% by Oleg Golubitsky, Vadim Mazalov and Stephen M. Watt

n=size(S,1);
if n==1
    distance=norm(point-S(1,:));
    projection=S(1,:)';
else
    for t=1:n
        translatedS(t,:)=S(t,:)-S(1,:);
    end
    b=(point-S(1,:))';
    A=translatedS(2:end,:)';
    top=(A'*A);
    top=top+.000000001*rand(size(top));
    bottom=(A'*b);
    bottom=bottom+.000000001*rand(size(bottom));
    alpha = top\bottom;
    
    [R, pivcol] = frref(A);
    A = A(:, pivcol);
    P = A*inv(A'*A)*A';
    pprime = P * b;
    
    posflag=1;
    for ii=1:size(alpha,1)
        if alpha(ii)<0
            posflag=0;
        end
    end
    if sum(alpha)<=1 && posflag==1
        %projection inside simplex
        distance=norm(pprime-b);
        projection=pprime+S(1,:)';
        return;
    else if posflag==0
            Sprime(1,:)=S(1,:);
            count=2;
            for ii=1:size(alpha,1)
                if alpha(ii)>0
                    Sprime(count,:)=S(ii+1,:);
                    count=count+1;
                end
            end
            [distance, projection]= distanceToSimplex(point,Sprime);
            return;
        else
            [distance,projection] =distanceToSimplex(point,S(2:end,:));
            return;
        end
    end
end
        
        
        
