function topologyMap = retrieveTopology(dir_path, topologyMap)
fileList = getAllFiles(dir_path);
for i = 1:length(fileList)
    display(i);
    file = fileList{i};
    load(file);
    keySet = keys(topologyStatsMap);
    for j = 1:length(keySet)
        camConnection = keySet{j};
        subMap = topologyStatsMap(camConnection);
        statsKey = keys(subMap);
        for m = 1:length(statsKey)
            freq = statsKey{m};
            tmp = subMap(freq);
            numbers = tmp{1};   
            if ~isKey(topologyMap, camConnection)
                hopMap = containers.Map('KeyType','char','ValueType','any');
                hopMap(freq) = numbers;
                topologyMap(camConnection) = hopMap;
                clear hopMap;
            else
                hopMap = topologyMap(camConnection);
                if ~isKey(hopMap,freq)                    
                    hopMap(freq) = numbers;
                else
                    tmpNum = hopMap(freq);
                    tmpNum = tmpNum+numbers;
                    hopMap(freq) = tmpNum;
                    clear tmpNum;
                end
                topologyMap(camConnection) = hopMap;
                clear hopMap;
            end
        end
    end
end