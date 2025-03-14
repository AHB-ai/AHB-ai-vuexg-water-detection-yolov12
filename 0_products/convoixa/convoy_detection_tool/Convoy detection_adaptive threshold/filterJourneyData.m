function dataMap = filterJourneyData(journeyMap, size)
dataMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(journeyMap);
for i = 1:length(keySet)
    vrm = keySet{i};
    val = journeyMap(vrm);
    if length(val)>size
        dataMap(vrm) = val;
    end
end
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