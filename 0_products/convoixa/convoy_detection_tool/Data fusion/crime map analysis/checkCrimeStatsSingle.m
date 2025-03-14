function [totalCrime] = checkCrimeStatsSingle(date, anprId, crimeMap, anprMap, searchRadius)
totalCrime = 0;
if ~isKey(crimeMap, date)
    disp('No crime data for this month');
else
    subCrimeMap = crimeMap(date);
    coordKeys = keys(subCrimeMap);
    if isKey(anprMap, anprId)
        anprData = anprMap(anprId);
        anprLat = anprData.latitude;
        anprLon = anprData.longitude;
        totalCrime = 0;
        for m=1:length(coordKeys)
            coords = coordKeys{m};
            crimes = subCrimeMap(coords);
            tmp = strfind(coords,' ');
            crimeLat = str2double(coords(1:tmp(1)));
            crimeLon = str2double(coords(tmp(1)+1:end));
            dist = calculateDistance(anprLat, anprLon, crimeLat, crimeLon);
            if dist<=searchRadius
                totalCrime = totalCrime + length(crimes);
            end
        end
        %display('Done !');
    else
        %display('Done !');
    end
end
end


