% This script is to detect single session for single file
% INPUT: 
% -inputData: intermediate format of ANPR data
% -output_dir: output directory to store the results
% -session_break: is the minimum time break between sessions (hour)
% -num_in_session: is the minimum number within one session
% -OUTPUT:
% -single_sessionMap: is the matlab data format store single session
% results
% Haiyue@May 2015
function [factoryMap] = getFactoryInfo(dir_path, output_dir)

factoryMap = containers.Map('KeyType','char','ValueType','any');
if ~exist(output_dir, 'file')
    mkdir(output_dir);
end
disp('Start scanning all reads...');
fileList = getAllFiles(dir_path);
for idx = 1:10
    tic;
    inputData = fileList{idx};
    load(inputData);
    data = output.data;
    for j=1:length(data)  
        info = struct;
        carID = data{j,1};        
        info.make = data{j,6};
        info.tax = data{j,7};
        info.model = data{j,8};
        info.color = data{j,9};
        info.time = [data{j,2} ' ' data{j,3}];
        tf = isKey(factoryMap,carID);
        if tf==0
            info_array{1} = info;
            factoryMap(carID) = info_array;
            clear info_array;
        end
        if tf==1
            info_array = factoryMap(carID);
            info_array{length(info_array)+1} = info;
            factoryMap(carID) = info_array;
            clear info_array;
        end
    end
    toc;
end
