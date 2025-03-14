function dataMap = adaptiveFilterJourneyData_v2(journeyMap, sizeMap)
keySize = keys(sizeMap);
tmpList = [];
ct=1;
for i = 1:length(keySize)
    temp = keySize{i};
    subMap = sizeMap(temp);
    keySet = keys(subMap);
    for j = 1:length(keySet)
        size = subMap(keySet{j});
        tmpList(ct) = size;
        ct=ct+1;
    end
end
min_num = min(tmpList);
dataMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(journeyMap);
for i = 1:length(keySet)
    vrm = keySet{i};
    val = journeyMap(vrm);
    if length(val)>=min_num
        val = journeyMap(vrm);
        camId = val{1}.camID;
        timeNum = val{1}.time;
        day = getDayOfWeek(timeNum);
        sessionSizeMap = sizeMap(day);        
        if isKey(sessionSizeMap,camId)
            journey_size = sessionSizeMap(camId);
        else
            journey_size = min_num;
        end
        if length(val)>=journey_size
            dataMap(vrm) = val;
        end
    end
end

clear keySet;
dataMap = filterDataMap(dataMap, 2);

function dataMap = filterDataMap(dataMap, min_cam)
keySet = keys(dataMap);
for i=1:length(keySet)
    val = dataMap(keySet{i});
    camIdMap = containers.Map('KeyType','char','ValueType','any');
    for j=1:length(val)
        camId = val{j}.camID;
        if ~isKey(camIdMap, camId)
            camIdMap(camId) = 1;
        else
            num = camIdMap(camId);
            camIdMap(camId) = num+1;
        end
    end
    if length(camIdMap) < min_cam
        remove(dataMap, keySet{i});
    end
end