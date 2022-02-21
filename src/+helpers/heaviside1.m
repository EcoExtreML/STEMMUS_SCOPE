function Y = heaviside1(X)
% HEAVISIDE    Step function.
% MATLAB heaviside function from the symbolic toolbox is not supported by MATLAB compiler.
% This implementation is based on the workaround at 
% https://nl.mathworks.com/matlabcentral/answers/98695-why-do-i-receive-undefined-function-errors-for-heaviside-function-when-i-try-to-compile-it-in-a-fit#answer_108043

Y = zeros(size(X));
Y(X > 0) = 1;
Y(X == 0) = .5;
end
