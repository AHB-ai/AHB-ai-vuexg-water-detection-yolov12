function dataMap = adaptiveFilterJourneyData(journeyMap, sizeMap)
dataMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(journeyMap);
for i = 1:length(keySet)
   vrm = keySet{i};
   val = journeyMap(vrm);
   if length(val)>1 
       dataMap(vrm) = val;
   end
end
clear keySet;
dataMap = filterDataMap(dataMap, 2);
%dataMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(dataMap);
for i = 1:length(keySet)
   vrm = keySet{i};
   val = dataMap(vrm);
   camId = val{1}.camID;
   timeNum = val{1}.time;
   day = getDayOfWeek(timeNum);
   sessionSizeMap = sizeMap(day);
   if isKey(sessionSizeMap,camId)
       journey_size = sessionSizeMap(camId)+1;
   else
       journey_size = 4;
   end
   if length(val)<journey_size 
       remove(dataMap, keySet{i});
   end
end


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