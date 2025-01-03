function [output] = afgen(table,x)
%{
    function afgen.m intercept the value in the table
    authors: Danyang Yu (yudanyang123@gmail.com)
    date: 2025/01/01
%}

if x < table(1,1) | x > table(end,1)
    print('the value of developemnt stage is mistaken');
else
    dvslist  =   table(:,1).';
    loc      =   discretize([x],[-Inf dvslist Inf]);
    slope    =   (table(loc,2) - table((loc-1),2))/(table(loc,1)-table((loc-1),1));
    output   =   table(loc-1,2) + slope*(x - table(loc-1,1));
end
end

