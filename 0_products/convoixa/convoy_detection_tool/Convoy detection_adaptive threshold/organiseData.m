function dataList = organiseData(hashMap, scale)
len = length(hashMap);
number = floor(len/scale);
mod_number = mod(len,scale);
dataList = cell(number+1,1);
keySet = keys(hashMap);
for idx=1:number
    subMap = containers.Map('KeyType','char','ValueType','any');
    for i = ((idx-1)*(scale)+1):idx*scale
        key = keySet{i};
        val = hashMap(key);
        subMap(key) = val;
    end
    dataList{idx} = subMap;
    clear subMap;
end

subMap = containers.Map('KeyType','char','ValueType','any');
for j = ((number)*(scale)+1):((number)*(scale)+mod_number)
    key = keySet{j};
    val = hashMap(key);
    subMap(key) = val;
end
dataList{number+1} = subMap;
clear subMap;
end