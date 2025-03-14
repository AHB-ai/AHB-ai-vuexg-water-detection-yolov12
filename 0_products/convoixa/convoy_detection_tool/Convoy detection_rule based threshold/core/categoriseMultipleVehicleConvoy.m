%% Author
%  This script is to cluster n-vehicle convoys
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
% 

function [new_map, tempConvoy] = categoriseMultipleVehicleConvoy(multipleVehicleConvoy)
multipleVehicleConvoy_together = containers.Map('KeyType','char','ValueType','any');
tempConvoy = containers.Map('KeyType','char','ValueType','any');
keySet = keys(multipleVehicleConvoy);
for i=1:length(keySet)
    key = keySet{i};
    tmpval = multipleVehicleConvoy(key);
    for j=1:length(tmpval);
        val = tmpval{j};
        num_vehicles = val{1};
        content = val{2};
        [len,~] = size(content);
        R = rem(len,num_vehicles);
        if R==0
            % count the frequency for each vrm, if the frequency of each
            % vrm are the same, these vrms are always travelling together
            tmpMap = containers.Map('KeyType','char','ValueType','any');
            for m=1:len
                vrm = content{m,1};
                if ~isKey(tmpMap,vrm)
                    tmpMap(vrm)=1;
                else
                    num = tmpMap(vrm);
                    tmpMap(vrm) = num+1;
                end
            end
            tmp_array = zeros(1,num_vehicles);
            vrm_array = cell(1,num_vehicles);
            tmpKey = keys(tmpMap);
            for n=1:num_vehicles
                tmp_array(n) = tmpMap(tmpKey{n});
                vrm_array{n} = tmpKey{n};
            end
            std_tmp = std(tmp_array);
            mean_tmp = mean(tmp_array);
            perct = std_tmp/mean_tmp;
            if perct<0.1
                flag = 0;
            else
                flag = 1;
            end
            clear tmpKey;
            clear tmpMap;
            if flag==0
                if ~isKey(multipleVehicleConvoy_together, key)
                    results{1} = {vrm_array, content};
                    multipleVehicleConvoy_together(key) = results;
                    clear results;
                else
                    results = multipleVehicleConvoy_together(key);
                    results{length(results)+1} = {vrm_array, content};
                    multipleVehicleConvoy_together(key) = results;
                    clear results;
                end
            else
                if ~isKey(tempConvoy, key)
                    results{1} = {vrm_array, content};
                    tempConvoy(key) = results;
                    clear results;
                else
                    results = tempConvoy(key);
                    results{length(results)+1} = {vrm_array, content};
                    tempConvoy(key) = results;
                    clear results;
                end
            end
        else
            tmpMap = containers.Map('KeyType','char','ValueType','any');
            for m=1:len
                vrm = content{m,1};
                if ~isKey(tmpMap,vrm)
                    tmpMap(vrm)=1;
                else
                    num = tmpMap(vrm);
                    tmpMap(vrm) = num+1;
                end
            end
            vrm_array = cell(1,num_vehicles);
            tmpKey = keys(tmpMap);
            for n=1:num_vehicles
                vrm_array{n} = tmpKey{n};
            end
            clear tmpKey;
            clear tmpMap;
            if ~isKey(tempConvoy, key)
                results{1} = {vrm_array, content};
                tempConvoy(key) = results;
                clear results;
            else
                results = tempConvoy(key);
                results{length(results)+1} = {vrm_array, content};
                tempConvoy(key) = results;
                clear results;
            end
        end
    end
end
map = multipleVehicleConvoy_together;
new_map = refineMultipleConvoy(map);


function new_map = refineMultipleConvoy(map)
new_map = containers.Map('KeyType','char','ValueType','any');
keySet = keys(map);
for i=1:length(keySet)
    key = keySet{i};
    val = map(key);
    for j=1:length(val)
        content = val{j};
        vrms = content{1};
        new_key = '';
        for m=1:length(vrms)
            new_key = [new_key vrms{m} ' '];
        end
        if ~isKey(new_map, new_key)
            new_val{1} = content;
            new_map(new_key) = new_val;
        else
            convoy = content{2};
            test1 = convoy(:,2);
            new_val = new_map(new_key); 
            flag = 1;
            for m=1:length(new_val)
                content_cmp = new_val{m};
                convoy_cmp = content_cmp{2};
                test2 = convoy_cmp(:,2);
                if ~isequal(test1,test2)
                    flag = 0;
                end
                clear test2;
            end
            if flag==0
                new_val{length(new_val)+1} = content;   
            end
            new_map(new_key) = new_val;
        end
        clear new_val;
        clear new_key;
    end
    clear test1;
end