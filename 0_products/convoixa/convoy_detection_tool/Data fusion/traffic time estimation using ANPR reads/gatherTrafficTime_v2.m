function gatherTrafficTime_v2(inputFile, output_dir)
disp('Start processing...');
if ~exist(output_dir, 'file')
    mkdir(output_dir);
end
[~,name,~] = fileparts(inputFile);
tmp = strfind(name, '_');
date = name(1:tmp(1)-1);
flag = strfind(date, '-');
day = date(1:flag(1)-1);
month = date(flag(1)+1:flag(2)-1);
year = date(flag(2)+1:end);

[~, dayName] = weekday(datenum(date,'dd-mm-yyyy'));
%tag = distributeDay(daynumber);
trafficMap = refineTrafficMap(inputFile);
key = keys(trafficMap);

for i=1:length(key)
    camConnection = key{i};
    temp = trafficMap(camConnection);
    results_dir = [output_dir '\' dayName '\' day '\' month '\' year];
    if ~exist(results_dir, 'file')
        mkdir(results_dir);
    end
    refFile = [results_dir '\' camConnection '.mat'];
    %results = [];
    %if exist(refFile, 'file')
    %    load(refFile);
    %    results = [results;temp];
    %else
        results = temp;
    %end
    save(refFile,'results');
    clear results;
    clear file;
end

% function tag = distributeDay(daynumber)
% switch daynumber
%     case 1
%         tag = 'weekend';
%     case 2
%         tag = 'weekdays';
%     case 3
%         tag = 'weekdays';
%     case 4
%         tag = 'weekdays';
%     case 5
%         tag = 'weekdays';
%     case 6
%         tag = 'weekdays';
%     case 7
%         tag = 'weekend';
% end
