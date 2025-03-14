% This script summarise the crime map statistis given a month, ANPR id, and
% search radius. 
% INPUT:
% -month: as there is no exact date of the crimes, have to use month ('2015-03')
% -anprId: it is the id of camera ('ANPR1.10')
% -crimeMap: this is generated using crimeMap2struct
% -anprMap: this is included in this package, please refer to main.m for
% example
% -searchRadius: it the number of radius that is around the location of the
% camera
% -output_dir: it is where the user wants to store the output report.
% OUTPUT:
% -crimeStats: it is a cell array that store all results.
% -csv file: this can be found in the output_dir
function [crimeStats] = checkCrimeStats(month, anprId, crimeMap, anprMap, searchRadius, output_dir)
disp('Start processing...');
if ~exist(output_dir, 'file')
    mkdir(output_dir);
end

subCrimeMap = crimeMap(month);
coordKeys = keys(subCrimeMap);
anprData = anprMap(anprId);
anprLat = anprData.latitude;
anprLon = anprData.longitude;
count=1;
totalCrime = 0;
for m=1:length(coordKeys)
    coords = coordKeys{m};
    crimes = subCrimeMap(coords);
    tmp = strfind(coords,' ');
    crimeLat = str2double(coords(1:tmp(1)));
    crimeLon = str2double(coords(tmp(1)+1:end));
    dist = calculateDistance(anprLat, anprLon, crimeLat, crimeLon);
    if dist<=searchRadius
        crimeStats{count,1} = coords;
        crimeStats{count,2} = dist; 
        totalCrime = totalCrime + length(crimes); 
        %crimeStats{count,3} = crimes;
        map = containers.Map('KeyType','char','ValueType','any');
        [map] = statsCrimeType(crimes,map);
        keySet = keys(map);
        for n=1:2:length(keySet)
            key = keySet{n};
            num = map(key);
            crimeStats{count,n+2} = key;
            crimeStats{count,n+3} = num;
        end
        count=count+1;
        clear map;
    end
end
crimeStats = sortrows(crimeStats,2);
if exist('crimeStats','var')
   output = [output_dir '\' month '-' anprId '-' num2str(searchRadius) '_report.csv'];
   simplemat2csv(crimeStats, output)
end
disp('Done !');
end

function [crimeTypeMap] = statsCrimeType(crimeData,crimeTypeMap)

for i=1:length(crimeData)
    crimeType = crimeData{i}.type;
    flag = isKey(crimeTypeMap, crimeType);
    if flag==0
        crimeTypeMap(crimeType) = 1;
    end
    if flag==1
        ct = crimeTypeMap(crimeType);
        ct = ct+1;
        crimeTypeMap(crimeType) = ct;
        clear ct;
    end
end
end