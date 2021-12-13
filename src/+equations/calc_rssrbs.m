function [rss,rbs] = calc_rssrbs(SMC,LAI,rbs)

%rss            = 10*exp(35.63*(0.25-SMC));
%if rss>1000,
    %rss=1000;
%elseif rss<30,
    %rss=30;
%end
rss =11.2*exp(0.3563*100.0*(0.38-SMC));
%rss = exp(7.9-1.6*(SMC-0.0008)/(0.38-0.0008));
%if  rss<70,
  %  rss=70;
%end
rbs            = rbs*LAI/4.3;