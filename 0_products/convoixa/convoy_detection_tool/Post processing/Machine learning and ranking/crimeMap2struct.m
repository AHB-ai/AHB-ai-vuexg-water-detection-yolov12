% This script is to load crime map to a matlab data format (hash map), the
% key is the coordinates where the crime happens.
% Haiyue@Mar 2015
% INPUT:
% -dir_path: is the directory that stores raw crime map data ('..\crime map analysis\data');
% OUTPUT:
% -crimeMap: is the matlab data format
function [crimeMap] = crimeMap2struct(dir_path)
fileList = getAllFiles(dir_path);
crimeMap = containers.Map('KeyType','char','ValueType','any');
for index = 1:length(fileList)    
    filename = fileList{index};
    [~,name] = fileparts(filename);
    nameKey = name(1:7);
    data = load_data_csv(filename, 'all');
    crimeMap_by_date = containers.Map('KeyType','char','ValueType','any');
    len = length(data);
    for id=2:len
        crimeInfo = struct;
        lat = data{id,6};
        lon = data{id,5};
        crime_key = [lat ' ' lon];
        crimeInfo.loc = data{id,7};
        crimeInfo.type = data{id,10};
        crimeInfo.date = data{id,2};
        if isKey(crimeMap_by_date, crime_key)
            tmp = crimeMap_by_date(crime_key);
            tmp{length(tmp)+1} = crimeInfo;
            crimeMap_by_date(crime_key) = tmp;
            clear tmp;
        elseif ~isKey(crimeMap_by_date, crime_key)
            tmp{1} = crimeInfo;
            crimeMap_by_date(crime_key) = tmp;
            clear tmp;
        end
        clear crimeInfo;
        clear crime_key;        
    end
    crimeMap(nameKey) = crimeMap_by_date;
end
end

