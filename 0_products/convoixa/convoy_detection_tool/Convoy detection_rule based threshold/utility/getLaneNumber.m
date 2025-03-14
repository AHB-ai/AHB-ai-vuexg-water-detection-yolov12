function laneNum = getLaneNumber(anprMap, camId)
if isKey(anprMap, camId)
    temp = anprMap(camId);
    laneNum = temp.laneNum;
    clear temp;
else
    laneNum = 10;
end
end

