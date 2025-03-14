function [convoyOutput_svrm, convoyOutput_dvrm] = convoyDetectionInterface_Adaptive(anprMap, input_path, journey_path, convoy_path, date_start,date_end, time_start, time_end)
t0 = 734139;% for time stamp
convoyOutput_svrm = containers.Map('KeyType','char','ValueType','any');
convoyOutput_dvrm = containers.Map('KeyType','char','ValueType','any');
load anprMap;
timeNum_start = time2timeNum(time_start);
timeNum_end = time2timeNum(time_end);
if ~exist(input_path, 'file')
    msg = sprintf('Error, %s does not exist, please check !', dir_path);
    fprintf(msg);
end
if ~exist(journey_path, 'file')
    mkdir(journey_path);
end
if ~exist(convoy_path, 'file')
    mkdir(convoy_path);
end

dateList = getDates(date_start, date_end);
convoyList = cell(length(dateList));

for ii=1:length(dateList)
    disp(ii);
    date = dateList{ii};
    datestr = str2date(date);
    inputFile = [input_path '\' datestr '_export.mat'];
    convoyFile = [convoy_path '\' datestr '_export.mat'];
    journeyFile = [journey_path '\' datestr '_journey.mat'];
    convoyMap = findConvoy(datestr, anprMap, inputFile, journeyFile, convoyFile, journey_path, convoy_path);
    convoyList{ii} = {convoyMap,datestr};
end

end
