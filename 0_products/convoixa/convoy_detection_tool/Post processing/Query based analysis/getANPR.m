function read = getANPR(data,map)
keySet = keys(map);
key1 = data{3};
key2 = data{4};
temp = map(keySet{key1});
read = temp{key2}{1};
end
