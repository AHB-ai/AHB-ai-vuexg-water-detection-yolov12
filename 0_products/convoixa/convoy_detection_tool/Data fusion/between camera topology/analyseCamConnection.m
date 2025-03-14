function analyseCamConnection(journeyMap, camConnectMap, date, output_folder, max_hop)
if ~exist(output_folder, 'file')
    mkdir(output_folder);
end
keySet = keys(journeyMap);
for i=1:length(keySet)
    display(i);
    subMap = containers.Map('KeyType','char','ValueType','any');
    key = keySet{i};
    val = journeyMap(key);
    data_array = cell(length(val),3);
    for j=1:length(val)
        time = val{j}.time;
        camID = val{j}.camID;
        pos = val{j}.pos;
        data_array(j,:)={time, camID, pos};
    end
    data_array = sortrows(data_array,1);   
    [length_data,~] = size(data_array);
    for m=1:length_data
        anprId = data_array{m,2};
        anprId = camNameCorrection(anprId);
        num_hop = 1;
        tmp_anprId_array = {};
        if length_data<max_hop
            tmp_length = length_data;
        else
            tmp_length = max_hop;
        end
        while (m+num_hop)<=tmp_length
            tmp_idx = m+num_hop;
            anprId_nxt = data_array{tmp_idx,2};
            anprId_nxt = camNameCorrection(anprId_nxt);
            if num_hop>1
                tmp_anprId = data_array{tmp_idx-1,2};
                tmp_anprId_array{num_hop-1} = tmp_anprId;      
            end
            tmpKey = [anprId ' ' anprId_nxt];
            if ~isKey(subMap, tmpKey)
                info{1} = {num_hop, tmp_anprId_array};
                subMap(tmpKey) = info;
                clear info;
            else
                info = subMap(tmpKey);
                info{length(info)+1} = {num_hop, tmp_anprId_array};
                subMap(tmpKey) = info;
                clear info;
            end
            num_hop = num_hop+1;            
        end
    end
    camConnectMap(key) = subMap;    
end
save([output_folder '\' date '_camConnection.mat'],'camConnectMap');
end