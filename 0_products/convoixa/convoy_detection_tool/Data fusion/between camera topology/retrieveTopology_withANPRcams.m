function [topologyMap_hop2, topologyMap_hop3] = retrieveTopology_withANPRcams(dir_path, topologyMap_hop2, topologyMap_hop3)
fileList = getAllFiles(dir_path);
tic;
for i = 1:length(fileList)
    display(i);
    file = fileList{i};
    load(file);
    keySet = keys(topologyStatsMap);
    for j = 1:length(keySet)
        camConnection = keySet{j};
        tmp = strfind(camConnection,'ANPR');
        if length(tmp)==2
            subMap = topologyStatsMap(camConnection);
            if isKey(subMap, '2')
                tmp = subMap('2');
                val = tmp{2};
                for m=1:length(val)
                    camId_tmp = val{m}{1}{1};
                    camId = camNameCorrection(camId_tmp);
                    topologyMap_hop2 = inputTopology(topologyMap_hop2, camConnection, camId);
                    clear camId;
                end
            end
            if isKey(subMap, '3')
                tmp = subMap('3');
                val = tmp{2};
                for m=1:length(val)
                    tmp1 = val{m}{1}{1};
                    tmp2 = val{m}{1}{2};
                    cam1 = camNameCorrection(tmp1);
                    cam2 = camNameCorrection(tmp2);
                    camId = [cam1 ' ' cam2];
                    topologyMap_hop3 = inputTopology(topologyMap_hop3, camConnection, camId);
                    clear camId;
                end
            end
%             if isKey(subMap, '4')
%                 tmp = subMap('4');
%                 val = tmp{2};
%                 for m=1:length(val)
%                     tmp1 = val{m}{1}{1};
%                     tmp2 = val{m}{1}{2};
%                     tmp3 = val{m}{1}{3};
%                     cam1 = camNameCorrection(tmp1);
%                     cam2 = camNameCorrection(tmp2);
%                     cam3 = camNameCorrection(tmp3);
%                     camId = [cam1 ' ' cam2 ' ' cam3];
%                     topologyMap_withANPRcams = inputTopology(topologyMap_withANPRcams, '4', camConnection, camId);
%                     clear camId;
%                 end
%             end
        end
    end
end
toc;
end 

function topologyMap = inputTopology(topologyMap, camConnection, camId)
    if ~isKey(topologyMap, camConnection)
        camArrayMap = containers.Map('KeyType','char','ValueType','any');
        camArrayMap(camId) = 1;
        topologyMap(camConnection) = camArrayMap;
        clear camArrayMap;
    else
        camArrayMap = topologyMap(camConnection);
        if ~isKey(camArrayMap, camId)
            camArrayMap(camId) = 1;
        else
            tmpNum = camArrayMap(camId);
            tmpNum = tmpNum+1;
            camArrayMap(camId) = tmpNum;
        end
        topologyMap(camConnection) = camArrayMap;
        clear camArrayMap;
    end
end