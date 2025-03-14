
% This script search all files and save them in a hash map for quick
% access in the future
% Haiyue @Feb 2015

function pathMap = build_path_map(dir_path)
pathMap = containers.Map('KeyType','char','ValueType','any');
fileList = getAllFiles(dir_path);
% search all files and save in a hash map, with the date is the key
for index = 1:length(fileList)
    % descriptor file is excluded
    
    full_path = fileList{index};
    tmp = strfind(full_path, '\');
    lg = length(tmp);
    file_name = full_path((tmp(lg)+1):end);
    filetag = file_name(1:15);
    temp = isKey(pathMap, filetag);
    if temp == 0
        file_info = struct;
        tp = strfind(file_name, 'Predefined');
        if ~isempty(tp)
            file_info.predefined = full_path;
        end
        if isempty(tp)
            file_info.journey = full_path;
        end
        pathMap(filetag)= file_info;
        clear file_info;
    end
    if temp == 1
        tmp_file_info = pathMap(filetag);
        tp = strfind(file_name, 'Predefined');
        if  ~isempty(tp)
            tmp_file_info.predefined = full_path;
        end
        if isempty(tp)
            tmp_file_info.journey = full_path;
        end
        pathMap(filetag) = tmp_file_info;
        clear file_path;
    end
    
end