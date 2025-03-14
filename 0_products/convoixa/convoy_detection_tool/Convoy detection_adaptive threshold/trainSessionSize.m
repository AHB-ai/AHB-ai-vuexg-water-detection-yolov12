function [sessionSizeMap, sessionSizeMap_date] = trainSessionSize(sessionSizeMap, sessionSizeMap_date, input_path, journey_path, date_start,date_end)
if ~exist(input_path, 'file')
    msg = sprintf('Error, %s does not exist, please check !', dir_path);
    display(msg);
end
if ~exist(journey_path, 'file')
    mkdir(journey_path);
end

dateList = getDates(date_start, date_end);

for ii=1:length(dateList)
    display(ii);
    date = dateList{ii};
    datestr = str2date(date);
    journeyFile = [journey_path '\' datestr '_journey.mat'];
    disp('Extracting journey information...');
    if ~exist(journeyFile, 'file')
        [journeyMap] = singleJourney(output, journey_path);
    else
        load(journeyFile);
    end
    keySet = keys(journeyMap);
    for jj=1:length(keySet)        
        journey = journeyMap(keySet{jj});
        camID = journey{1}.camID;
        time = journey{1}.time;
        size = length(journey);        
        if ~isKey(sessionSizeMap, camID)
            data.min = size;
            data.max = size;
            data.mean = size;
            sessionSizeMap(camID) = data; 
                       
            day = getDayOfWeek(time);
            dayMap = containers.Map('KeyType','char','ValueType','any');
            dayMap(day) = data;
            sessionSizeMap_date(camID) = dayMap;
            clear dayMap;
            clear data;
        else
            tmpData = sessionSizeMap(camID);
            if size<tmpData.min
                tmpData.min = size;
            end
            if size>tmpData.max
                tmpData.max = size;
            end
            tmpMean = tmpData.mean;
            tmpData.mean = (tmpMean+size)/2;
            sessionSizeMap(camID) = tmpData;
            clear tmpData;
            clear tmpMean;
            
            tmpData_date = sessionSizeMap_date(camID);
            if ~isKey(tmpData_date,day)
                data.min = size;
                data.max = size;
                data.mean = size;
                tmpData_date(day) = data;
                sessionSizeMap_date(camID) = tmpData_date;
                clear tmpData_date;
                clear data;
            else
                tmpData = tmpData_date(day);
                if size<tmpData.min
                    tmpData.min = size;
                end
                if size>tmpData.max
                    tmpData.max = size;
                end
                tmpMean = tmpData.mean;
                tmpData.mean = (tmpMean+size)/2;
                tmpData_date(day) = tmpData;
                sessionSizeMap_date(camID) = tmpData_date;
                clear tmpMean;
                clear tmpData_date;
                clear tmpData;
            end
        end
    end
end