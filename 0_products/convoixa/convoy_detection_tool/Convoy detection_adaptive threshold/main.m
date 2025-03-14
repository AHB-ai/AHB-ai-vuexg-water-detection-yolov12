dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Convoy Analysis\convoy algorithm\input data\converted ANPR reads';
iopath = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Convoy Analysis\convoy algorithm\adaptive session size\output';
journey_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Convoy Analysis\convoy algorithm\output data\output_journey_v2';
load anprMap;
search_window = 0.5;

fileList = getAllFiles(dir_path);
for ii = 234:length(fileList)
    disp(ii);
    rawFile = fileList{ii};
    analyseSessionSize(rawFile, journey_path, anprMap, search_window, iopath);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Convoy Analysis\convoy algorithm\adaptive session size\output';
fileList = getAllFiles(dir_path);
statsMap = containers.Map('KeyType','char','ValueType','any');
statsMap_Mon= containers.Map('KeyType','char','ValueType','any');
statsMap_Tue = containers.Map('KeyType','char','ValueType','any');
statsMap_Wed = containers.Map('KeyType','char','ValueType','any');
statsMap_Thu = containers.Map('KeyType','char','ValueType','any');
statsMap_Fri = containers.Map('KeyType','char','ValueType','any');
statsMap_Sat = containers.Map('KeyType','char','ValueType','any');
statsMap_Sun = containers.Map('KeyType','char','ValueType','any');
statsMap_Week = containers.Map('KeyType','char','ValueType','any');
statsMap_Weekend = containers.Map('KeyType','char','ValueType','any');

for i=1:length(fileList)
    disp(i);
    file = fileList{i};
    [~,filename,~] = fileparts(file);
    flag = strfind(filename, '_');
    date = filename(1:flag(1)-1);
    [~, dayName] = weekday(datetime(date,'dd-mm-yyyy'));
    load(file);
    statsMap = calculateStatas(statsMap, pairMap);
    switch dayName
        case 'Mon'
            statsMap_Mon = calculateStatas(statsMap_Mon, pairMap);
            statsMap_Week = calculateStatas(statsMap_Week, pairMap);
        case 'Tue'
            statsMap_Tue = calculateStatas(statsMap_Tue, pairMap);
            statsMap_Week = calculateStatas(statsMap_Week, pairMap);
        case 'Wed'
            statsMap_Wed = calculateStatas(statsMap_Wed, pairMap);
            statsMap_Week = calculateStatas(statsMap_Week, pairMap);
        case 'Thu'
            statsMap_Thu = calculateStatas(statsMap_Thu, pairMap);
            statsMap_Week = calculateStatas(statsMap_Week, pairMap);
        case 'Fri'
            statsMap_Fri = calculateStatas(statsMap_Fri, pairMap);
            statsMap_Week = calculateStatas(statsMap_Week, pairMap);
        case 'Sat'
            statsMap_Sat = calculateStatas(statsMap_Sat, pairMap);
            statsMap_Weekend = calculateStatas(statsMap_Weekend, pairMap);
        case 'Sun'
            statsMap_Sun = calculateStatas(statsMap_Sun, pairMap);
            statsMap_Weekend = calculateStatas(statsMap_Weekend, pairMap);
    end
    clear dayName;
    clear pairMap;
end