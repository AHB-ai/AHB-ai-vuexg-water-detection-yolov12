load anprMap;
load sizeMap;
% initilise some thresholds for convoy detection
session_break = 5; % in hours

dir_path = 'C:\Users\hy0006\Project\POLARBEAR\POLARBEAR.ALG\data.input';
journey_path = 'C:\Users\hy0006\Project\POLARBEAR\POLARBEAR.ALG\data.output\journey';
convoy_path = 'C:\Users\hy0006\Project\POLARBEAR\POLARBEAR.ALG\data.output\convoy_trajectory';
rawFileList = getAllFiles(dir_path);

date = '20-08-2015';
journeyFile = [journey_path '\' date '_journey.mat'];
rawFile = [dir_path '\' date '_export.mat'];
load(rawFile);
load(journeyFile);


%------------------------------------------------------------------------%
session_break = 5;
load('20-08-2015_journey.mat');
load anprMap
load sizeMap;
load topologyStats;
load camMap;

% reduce data size by applying adaptive session size threshold
%tmpMap = filterJourneyData_adaptive(journeyMap, sizeMap);
tmpMap = filterJourneyData(journeyMap, session_break);

% ranking the tmpMap based on size of journey
keySet = keys(tmpMap);
tmpTable = zeros(length(keySet),2);
for i=1:length(keySet)
    val = tmpMap(keySet{i});
    tmpTable(i,1) = length(val);
    tmpTable(i,2) = i;
end
rankTable = sortrows(tmpTable,1);

% change the data format 
for i=1:length(keySet)
    val = tmpMap(keySet{i});
    new_val = cell(length(val),3);
    for j=1:length(val)
        new_val{j,1} = val{j}.time;
        camID = val{j}.camID;
        camID(camID==' ')='';
        new_val{j,2} = camID;
        new_val{j,3} = val{j}.pos;
    end
    tmpMap(keySet{i}) = new_val;
end

[lenRankTable,~]=size(rankTable);
keySet = keys(tmpMap);
for i=1:lenRankTable
    idx_seed = rankTable(i,2);
    len_seed = rankTable(i,1);
    val_seed = tmpMap(keySet{idx_seed});
    st_time_seed = val_seed{1,1};
    ed_time_seed = val_seed{len_seed,1};
    rankTable(i,3) = st_time_seed;
    rankTable(i,4) = ed_time_seed;
end
tic;convoyArray_1 = detectConvoy_Trajectory(rankTable, tmpMap, anprMap, camMap, session_break);toc;

save('C:\Users\hy0006\Project\POLARBEAR\POLARBEAR.ALG\alg.convoy detection trajectory\convoyArray_1.mat','convoyArray_1');
% 