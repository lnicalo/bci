function [c,ceq] = constraint(x)
c=[]; 
ceq = [norm(x(:,1)) - 1;norm(x(:,2)) - 1;];
end
