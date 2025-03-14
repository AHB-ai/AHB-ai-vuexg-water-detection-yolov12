function statsTable = createStatsTable(statsMap)
keySet = keys(statsMap);
for i =1:length(keySet)
    key = keySet{i};
    statsTable{i,1} = key;
    val = statsMap(key);
    num = val.num;
    statsTable{i,2} = num;
    proTable = val.proTable;
    for j = 2:length(proTable)
        statsTable{i,j+1} = proTable{j};
    end
end