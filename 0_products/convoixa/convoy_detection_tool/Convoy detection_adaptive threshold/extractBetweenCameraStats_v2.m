function [statsMap,connectionMap] = extractBetweenCameraStats_v2(statsMap, connectionMap, dateStr, pairMap, pairMap_global, timewindow)
keySet = keys(pairMap);
dateNum = (datenum(dateStr, 'dd-mm-yyyy')-734139)*24*3600;
for i=1:length(keySet)
    vrm = keySet{i};
    flag = strfind(vrm, ' ');
    vrm1 = vrm(1:flag(1)-1);
    vrm2 = vrm(flag(1)+1:end);
    key_o = vrm;
    key_r = [vrm2 ' ' vrm1];
    if ~isKey(pairMap_global, key_o) && ~isKey(pairMap_global, key_r) 
        pairs = pairMap(vrm);
        for j=1:length(pairs)
            time = pairs{j}{1};
            camID = pairs{j}{2};
            flag = strfind(camID, 'ANPR');
            if ~isempty(flag)
                time_diff = abs(pairs{j}{1} - pairs{j}{3});
                if time_diff<=timewindow
                    timeOfDay = time - dateNum;
                    timeLabel = judgeTimeOfDay(timeOfDay);
                    statsMap = saveData(statsMap, camID, time_diff,timeLabel);
                end
            end
            clear flag;
        end
        for j=1:length(pairs)-1
            % time of vehicle 1 passing the j camera
            time_diff_1 = abs(pairs{j}{1} - pairs{j}{3});
            time_diff_2 = abs(pairs{j+1}{1} - pairs{j+1}{3});
            camID_1 = pairs{j}{2};
            camID_2 = pairs{j+1}{2};
            flag1 = strfind(camID_1, 'ANPR');
            flag2 = strfind(camID_2, 'ANPR');
            if ~isempty(flag1) && ~isempty(flag2)
                if time_diff_1<=timewindow && time_diff_2<=timewindow
                    % time of day of vehicle 1 passing j camera
                    timeOfDay_1 = pairs{j}{1} - dateNum;
                    % camera id of j
                    
                    % time label of vehicle 1 passing j camera
                    timeLabel_1 = judgeTimeOfDay(timeOfDay_1);
                    timeOfDay_2 = pairs{j+1}{1} - dateNum;
                    route_name = [camID_1 ' ' camID_2];
                    
                    if ~isKey(connectionMap, route_name)
                        timeMap = containers.Map('KeyType','char','ValueType','any');
                        data = struct;
                        data.frequency = 1;
                        travellist(1) = timeOfDay_2 - timeOfDay_1;
                        data.time_travel = travellist;
                        timeMap(timeLabel_1) = data;
                        connectionMap(route_name) = timeMap;
                        clear timeMap;
                        clear data;
                        clear travellist;
                    else
                        timeMap = connectionMap(route_name);
                        if ~isKey(timeMap, timeLabel_1)
                            data = struct;
                            data.frequency = 1;
                            travellist(1) = timeOfDay_2 - timeOfDay_1;
                            data.time_travel = travellist;
                            timeMap(timeLabel_1) = data;
                            clear data;
                            clear travellist;
                        else
                            data = timeMap(timeLabel_1);
                            num = data.frequency;
                            data.frequency = num+1;
                            travellist = data.time_travel;
                            travellist(num+1) = timeOfDay_2 - timeOfDay_1;
                            data.time_travel = travellist;
                            timeMap(timeLabel_1) = data;
                            clear num;
                            clear data;
                            clear travellist;
                        end
                        connectionMap(route_name) = timeMap;
                        clear timeMap;
                    end
                    clear route_name;
                end
            end
            clear flag1;
            clear flag2;
        end
    else
        pairMap_global(key_o) = 1;
    end
end
end
function statsMap = saveData(statsMap, camID, time_diff,timeLabel)
if ~isKey(statsMap, camID)
    timeMap = containers.Map('KeyType','char','ValueType','any');
    data = struct;
    data.frequency = 1;
    list(1) = time_diff;
    data.time_diff = list;
    timeMap(timeLabel) = data;
    statsMap(camID) = timeMap;
    clear timeMap;
    clear data;
    clear list;
else
    timeMap = statsMap(camID);
    if ~isKey(timeMap, timeLabel)
        data = struct;
        data.frequency = 1;
        list(1) = time_diff;
        data.time_diff = list;
        timeMap(timeLabel) = data;
        clear data;
        clear list;
    else
        data = timeMap(timeLabel);
        num = data.frequency;
        data.frequency = num+1;
        list = data.time_diff;
        list(num+1) = time_diff;
        data.time_diff = list;
        timeMap(timeLabel) = data;
        clear num;
        clear data;
        clear list;
    end
    statsMap(camID) = timeMap;
    clear timeMap;
end
end
