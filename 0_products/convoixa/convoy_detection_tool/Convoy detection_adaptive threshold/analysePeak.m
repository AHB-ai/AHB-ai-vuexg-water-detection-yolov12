function [locs, bins, myFit, index] = analysePeak(data, scale)
myFit = fitdist(data, 'kernel');
index = linspace(min(data), max(data), scale);
%plot(index, pdf(myFit, index));
[~, locs] = findpeaks(pdf(myFit, index),'MinPeakHeight',max(pdf(myFit,index))/7, 'MinPeakDistance', 10);
[~, bins] = histogram(data, scale);
end