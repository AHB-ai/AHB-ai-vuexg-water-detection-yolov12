%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%% 
function output = sortJourney(input)
tmpArray = zeros(length(input),2);
for j=1:length(input)
    tmpArray(j,1) = j;
    tmpArray(j,2) = input{j}.time;
end
tmpArray = sortrows(tmpArray,2);
output = cell(length(input),1);
for m=1:length(input)
    idx = tmpArray(m,1);
    output{m} = input{idx};
end
clear tmpArray;
end