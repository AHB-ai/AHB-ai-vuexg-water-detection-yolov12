%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%% 
function globalMap = storeTime(globalMap, carId_cur, search_data, idx)
timeStamp = search_data{idx,3};
if ~isKey(globalMap, carId_cur)
    miniMap = containers.Map('KeyType','char','ValueType','any');
    miniMap(timeStamp)=1;
    globalMap(carId_cur) = miniMap;
    clear miniMap;
else
    miniMap = globalMap(carId_cur);
    miniMap(timeStamp)=1;
    globalMap(carId_cur) = miniMap;
    clear miniMap;
end