% map = processedConvoyMap_singleVRM
function vrmMap = getVrmMap(map)
vrmMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(map);
for i=1:length(keySet)
    vrm = keySet{i};
    val = map(vrm);
    len_val = length(val);
    if len_val>1
        data = cell(len_val,1);
        for j=1:len_val
            data{j} = val{j}{1};
        end
        vrmMap(vrm) = data;
    end
end
end

