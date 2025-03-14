function trainSessionSize_v2(anprMap, input_path, output_path, journey_path, date_start,date_end)

if ~exist(input_path, 'file')
    msg = sprintf('Error, %s does not exist, please check !', dir_path);
    display(msg);
end
if ~exist(journey_path, 'file')
    mkdir(journey_path);
end

dateList = getDates(date_start, date_end);

for ii=1:length(dateList)
    sessionSizeMap = containers.Map('KeyType','char','ValueType','any');
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
        if isKey(anprMap, camID)
            size = length(journey);
            if ~isKey(sessionSizeMap, camID)
                data(1) = size;
                sessionSizeMap(camID) = data;
                clear data;
            else
                tmpData = sessionSizeMap(camID);
                tmpData(length(tmpData)+1) = size;
                sessionSizeMap(camID) = tmpData;
                clear tmpData;
            end
        end
    end
    save([output_path '\' date '_size.mat'],'sessionSizeMap');    
end