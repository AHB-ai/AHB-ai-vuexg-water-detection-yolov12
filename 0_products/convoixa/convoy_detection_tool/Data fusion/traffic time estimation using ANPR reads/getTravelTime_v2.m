
% Haiyue@Aug 2015
function getTravelTime_v2(file, dir)
trafficMap = containers.Map('KeyType','char','ValueType','any');
[~,name,~] = fileparts(file);
tmp = strfind(name, '_');
date = name(1:tmp(1)-1);
output_file = [dir '\' date '_traffic.mat'];
if ~exist(output_file,'file')
    load(file);
    keySet = keys(journeyMap);
    for j=1:length(keySet)
        vrm = keySet{j};
        val = journeyMap(vrm);
        tmpdata = cell(length(val),2);
        for m=1:length(val)
            time = val{m}.time;
            camID = val{m}.camID;
            camID(camID==' ')='';
            camID = camNameCorrection(camID);
            tmpdata(m,:) = {camID, time};
            clear camID;
            clear time;
        end
        sortedData = sortrows(tmpdata,2);
        clear tmpdata;
        [len,~] = size(sortedData);
        if len>1
            for n=1:len-1
                camID = sortedData{n,1};
                time = sortedData{n,2};
                camID_nxt = sortedData{n+1,1};
                time_nxt = sortedData{n+1,2};
                time_dif = time_nxt - time;
                flag1 = strfind(camID, 'ANPR');
                flag2 = strfind(camID_nxt, 'ANPR');
                if ~isempty(flag1) && ~isempty(flag2)
                    camKey = [camID ' ' camID_nxt];
                    if ~isKey(trafficMap, camKey)
                        timeArray(1,1) = time;
                        timeArray(1,2) = time_dif;
                        trafficMap(camKey) = timeArray;
                        clear timeArray;
                    else
                        timeArray = trafficMap(camKey);
                        sizeArray = size(timeArray);
                        len = sizeArray(1);
                        timeArray(len+1,1) = time;
                        timeArray(len+1,2) = time_dif;
                        trafficMap(camKey) = timeArray;
                        clear timeArray;
                    end
                end
            end
        end
    end
    save(output_file,'trafficMap');
    clear trafficMap;
    clear sortedData;
end
end

