function dataMap = filterJourneyData_adaptive(journeyMap, sizeMap)
dataMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(journeyMap);
for i = 1:length(keySet)
    vrm = keySet{i};
    val = journeyMap(vrm);
    flag = 0;
    ct = 1;    
    while flag==0 && ct<=length(val)
        camId = val{ct}.camID;
        timeNum = val{ct}.time;
        day = getDayOfWeek(timeNum);
        tmpMap = sizeMap(day);
        if ~isempty(strfind(camId, 'ANPR')) && isKey(tmpMap, camId)
            session_size = tmpMap(camId);
            flag = 1;
        else
            ct=ct+1;
        end
        session_size = session_size+ct-1;
    end
    if length(val)>session_size
        dataMap(vrm) = val;
    end
end

