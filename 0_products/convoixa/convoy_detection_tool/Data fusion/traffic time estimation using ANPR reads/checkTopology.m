function checkTopology(input_dir, output_dir)
subFolder_List=ListSubfolders(input_dir);

for i=1:length(subFolder_List)
    tic;
    subFolder = subFolder_List{i};
    path = [input_dir '\' subFolder];
    fileList = getAllFiles(path);
    conMap = containers.Map('KeyType','char','ValueType','any');
    for j=1:length(fileList)
        file = fileList{j};
        [~, name, ~] = fileparts(file);
        load(file);
        data = results;
        dayOfWeek = sortrows(data,1);
        clear data;
        if ~isempty(dayOfWeek)
            [data] = grabSubsetByDayOfWeek(dayOfWeek, '08:30:00', 1800);
            if length(data)>100
                [locs, bins, myFit, index] = analysePeak(data);
                pkdata = {locs, bins, myFit, index};
            else
                pkdata = {};
            end
        else
            pkdata = {};
        end
        conMap(name) = pkdata;
    end
    output_path = [output_dir '\' subFolder];
    if ~exist(output_path, 'file')
        mkdir(output_path);
    end
    output_file = [output_path '\conMap.mat'];
    save(output_file, 'conMap');
    clear conMap;
    toc;
end
end