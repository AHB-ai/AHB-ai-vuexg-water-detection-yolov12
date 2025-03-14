function output = rankConvoy(input, rankingList)
rankArray = double(length(rankingList));
for i = 1:length(rankingList)
    rankArray(i) = rankingList{i};
end
output = sortrows(input, rankArray);
end