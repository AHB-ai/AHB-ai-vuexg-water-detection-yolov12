% map = processedConvoyMap_doubleVRM
function routeMap  = getConvoyWithSameRoutes(map)
globalMap = containers.Map('KeyType','char','ValueType','any');
routeMap = containers.Map('KeyType','char','ValueType','any');
tempList = {};
count = 1;
keySet = keys(map);
for i=1:length(keySet)
    val = map(keySet{i});
    for j=1:length(val)
        data = val{j}{1};
        group_anpr = data(:,3);
        tempList{count} = {group_anpr,i,j};
        count = count+1;
    end
end

for m=1:length(tempList)
    display(m);s
    data = tempList{m};
    group_anpr = data{1};
    anprStr = convert2str(group_anpr);
    for n=1:length(tempList)
        if m~=n
            if ~isKey(globalMap,num2str(n))
                data_cmp = tempList{n};
                group_anpr_cmp = data_cmp{1};
                anprStr_cmp = convert2str(group_anpr_cmp);
                if strcmp(anprStr,anprStr_cmp)              
                    if ~isKey(routeMap, anprStr)
                        key1 = data{2};
                        key2 = data{3};
                        temp = map(keySet{key1});
                        read = temp{key2}{1};
                        convoy{1} = {read,key1,key2};
                        key1_cmp = data_cmp{2};
                        key2_cmp = data_cmp{3};
                        temp_cmp = map(keySet{key1_cmp});
                        read_cmp = temp_cmp{key2_cmp}{1};
                        convoy{2} = {read_cmp,key1_cmp,key2_cmp};
                        routeMap(anprStr) = convoy;
                        clear convoy;
                        globalMap(num2str(n))=1;
                    else
                        convoy = routeMap(anprStr);
                        len = length(convoy);
                        key1 = data{2};
                        key2 = data{3};
                        temp = map(keySet{key1});
                        read = temp{key2}{1};
                        convoy{len+1} = {read,key1,key2};
                        key1_cmp = data_cmp{2};
                        key2_cmp = data_cmp{3};
                        temp_cmp = map(keySet{key1_cmp});
                        read_cmp = temp_cmp{key2_cmp}{1};
                        convoy{len+2} = {read_cmp,key1_cmp,key2_cmp};
                        routeMap(anprStr) = convoy;
                        clear convoy;
                        globalMap(num2str(n))=1;
                    end
                end
            end
        end
    end
end


