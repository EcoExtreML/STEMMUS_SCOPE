function Y = heaviside1(X)
%HEAVISIDE    Step function.
% MATLAB heaviside function from the symbolic toolbox is not supported by MATLAB compiler. 
Y = zeros(size(X));
Y(X > 0) = 1;
Y(X == 0) = .5;
end
