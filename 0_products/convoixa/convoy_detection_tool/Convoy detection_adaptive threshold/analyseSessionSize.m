function analyseSessionSize(rawFile, journey_path, anprMap, search_window, iopath)
[~,filename,~] = fileparts(rawFile);
tmp = strfind(filename, '_');
date = filename(1:tmp(1)-1);
journeyFile = [journey_path '\' date '_journey.mat'];
load(rawFile);
if ~exist(journeyFile, 'file')
    [journeyMap] = singleJourney(output, journey_path);
else
    load(journeyFile);
end
threshold_delt = search_window*60;
data = output.data;
index = output.index;
key = keys(index);
camMap = index(key{1});
%dataMap = filterJourneyData(journeyMap, 1);
scale = 10000;
dataList = organiseData(journeyMap, scale);
pairList = cell(length(dataList),1);

parfor i=1:length(pairList)
    %display(i);
    inputData = dataList{i};
    pairList{i} = pair_search(inputData, data, threshold_delt, camMap, anprMap);
end

pairMap = containers.Map('KeyType','char','ValueType','any');
for i=1:length(pairList)
    subMap = pairList{i};
    if ~isempty(subMap)
        key = keys(subMap);
        for j=1:length(key)
            val = subMap(key{j});
            pairMap(key{j}) = val;
        end
    end
end

save([iopath '\' date '_pair.mat'],'pairMap');
end

