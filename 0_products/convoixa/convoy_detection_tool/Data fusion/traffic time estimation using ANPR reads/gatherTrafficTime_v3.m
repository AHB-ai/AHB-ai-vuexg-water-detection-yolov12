function gatherTrafficTime_v3(inputFile, output_dir_1, output_dir_2)
disp('Start processing...');
if ~exist(output_dir_1, 'file')
    mkdir(output_dir_1);
end
if ~exist(output_dir_2, 'file')
    mkdir(output_dir_2);
end

[~,name,~] = fileparts(inputFile);
tmp = strfind(name, '_');
date = name(1:tmp(1)-1);
flag = strfind(date, '-');
day = date(1:flag(1)-1);
month = date(flag(1)+1:flag(2)-1);

[~, dayName] = weekday(datenum(date,'dd-mm-yyyy'));
trafficMap = refineTrafficMap(inputFile);
key = keys(trafficMap);

for i=1:length(key)
    camConnection = key{i};
    temp = trafficMap(camConnection);
    results_dir_1 = [output_dir_1 '\' dayName];
    results_dir_2 = [output_dir_2 '\' day '\' month];
    if ~exist(results_dir_1, 'file')
        mkdir(results_dir_1);        
    end
    if ~exist(results_dir_2, 'file')
        mkdir(results_dir_2);
    end    
    refFile_1 = [results_dir_1 '\' camConnection '.mat'];
    refFile_2 = [results_dir_2 '\' camConnection '.mat'];
    results = [];
    if exist(refFile_1, 'file')
        load(refFile_1);
        results = [results;temp];
    else
        results = temp;
    end
    save(refFile_1,'results');
    clear results;
    clear refFile_1;
    
    results = [];
    if exist(refFile_2, 'file')
        load(refFile_2);
        results = [results;temp];
    else
        results = temp;
    end
    save(refFile_2,'results');
    clear results;
    clear refFile_2;
end

