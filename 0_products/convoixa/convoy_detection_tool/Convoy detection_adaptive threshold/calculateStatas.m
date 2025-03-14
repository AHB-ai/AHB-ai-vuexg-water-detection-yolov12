% statsMap = containers.Map('KeyType','char','ValueType','any');
function statsMap = calculateStatas(statsMap, pairMap)
keySet = keys(pairMap);
for i=1:length(keySet)
    key = keySet{i};
    val = pairMap(key);
    camID = val{1}{2};
    if ~isKey(statsMap, camID)
        data = struct;
        data.num = 1;
        data.subMap = containers.Map('KeyType','char','ValueType','any');
        statsMap(camID) = data;
        clear data;
    else
        data = statsMap(camID);
        num = data.num;
        data.num = num+1;
        statsMap(camID) = data;
        clear data;
    end
    tmpData = statsMap(camID);
    subMap = tmpData.subMap;    
    route_name = camID;
    for j=2:length(val)
        camID_tmp = val{j}{2};
        route_name = [route_name ' ' camID_tmp];
        if ~isKey(subMap, route_name)
            subMap(route_name) = 1;
        else
            num = subMap(route_name);
            subMap(route_name) = num+1;
            clear num;
        end        
    end
    tmpData.subMap = subMap;
    statsMap(camID) = tmpData;
    clear tmpData;
end
end
