function statsMap = calculatePro(statsMap)
keySet = keys(statsMap);
for i=1:length(keySet)
    key = keySet{i};
    flag = strfind(key,'ANPR');
    if isempty(flag)
       remove(statsMap, key); 
    end
end

keySet = keys(statsMap);
for i=1:length(keySet)
    key = keySet{i};
    val = statsMap(key);
    num = val.num;
    subMap = val.subMap;
    anprKeys = keys(subMap);
    proArray = cell(100,1);    
    proArray{1,1} = num;
    for j=1:length(anprKeys)
        anpr = anprKeys{j};
        flag = strfind(anpr,' ');
        NumOfOccu = subMap(anpr);
        NumOfCams = length(flag)+1;
        tmpNum = proArray{NumOfCams,1};
        if isempty(tmpNum);
            proArray{NumOfCams,1} = NumOfOccu;
        else
            tmpNum = tmpNum + NumOfOccu;
            proArray{NumOfCams,1} = tmpNum;
        end
        clear flag;
        clear tmpNum;
    end
    baseNum = proArray{1,1};
    for m=1:100
        num = proArray{m,1};
        if ~isempty(num)
            proTable{1,m} = num/baseNum;
        end
    end
    val.proTable = proTable;
    clear proTable;
    clear proTable;
    statsMap(key) = val;
end

end