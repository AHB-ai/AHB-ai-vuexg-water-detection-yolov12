% Collect cam connection data
dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Convoy Analysis\convoy algorithm\output data\output_journey';
output_folder = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\between camera topology\automate\output';

fileList = getAllFiles(dir_path);
tic;
for i = 41:length(fileList)
    display(i);
    file = fileList{i};
    [~,name,~] = fileparts(file);
    tmp = strfind(name, '_');
    date = name(1:tmp(1)-1);
    output_file = [output_folder '\' date '_camConnection.mat'];
    if ~exist(output_file, 'file')
        load(file);
        camConnectMap = containers.Map('KeyType','char','ValueType','any');
        max_hop = 10;
        % analysCamConnection investigate the camera connection between
        % cameras, the data is stored in a primary hash map that contains sub
        % hash maps. The key for the primary hash map is the vrm, the sub
        % hash map records the camera connection for this vrm. The key for
        % the sub hash map is the camera connection such as 'ANPR23.3
        % ANPR23.2', and the corresponding value is in a 1-D cell array,
        % the first element is the number of hops, and the second element
        % is the camera in between if exists.
        analyseCamConnection(journeyMap, camConnectMap, date, output_folder, max_hop);
    end
end
toc;
% build topology between cams
dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\between camera topology\automate\output';
output_folder = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\between camera topology\automate\output_topology';
fileList = getAllFiles(dir_path);
tic;

for i = 1:length(fileList);
    display(i);
    file = fileList{i};
    [~,name,~] = fileparts(file);
    tmp = strfind(name, '_');
    date = name(1:tmp(1)-1);
    output_file = [output_folder '\' date '_topology.mat'];
    if ~exist(output_file, 'file')
        load(file);
        % analysTopology investigate each camConnectMap and summarise the
        % camera connection across all vrms and stored in a hash map. For
        % each camera connection, the resutls are stored in a sub hash map.
        % The key is the number of hops, and the value is the number of
        % vrms pass these cameras
        analyseTopology(camConnectMap, date, output_folder)
    end
end
toc;

% gather topology stats
topologyMap = containers.Map('KeyType','char','ValueType','any');
dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\between camera topology\automate\output_topology';
topologyMap = retrieveTopology(dir_path, topologyMap);

% refined topology to exclude mobile ANPR units
key = keys(topologyMap);
refinedTopologyMap = containers.Map('KeyType','char','ValueType','any');
ct=0;
for i=1:length(key)
    tmp = strfind(key{i},'ANPR');
    if length(tmp)==2
       camConnection = key{i};
       submap = topologyMap(camConnection);
       freqKey = keys(submap);
       topologyStats = cell(length(freqKey),2);
       for j=1:length(freqKey)
           freq = freqKey{j};
           num = submap(freq);           
           topologyStats(j,:) = {str2num(freq), num};
       end
       topologyStats = sortrows(topologyStats,1);
       refinedTopologyMap(camConnection) = topologyStats;
       clear topologyStats;
    end
end

% build topology matrix
key = keys(anprMap);
topology_matrix = cell(length(key)+1,length(key)+1);
for i=1:length(key)
    camId = key{i};
    topology_matrix{1,i+1} = camId;
    topology_matrix{i+1,1} = camId;
end

% add value to topology matrix
for i=2:length(key)+1
    camId_1 = topology_matrix{1,i};
    for j=2:length(key)+1
        camId_2 = topology_matrix{j,1};
        camConnection = [camId_1 ' ' camId_2];
        if isKey(refinedTopologyMap, camConnection)
            val = refinedTopologyMap(camConnection);
            freq = 0;
            [len,~] = size(val);
            for m=1:len
                num = val{m,1};
                if num==1
                    freq = val{m,2};
                end
            end
            sum_freq = sum(cellfun(@double,val(:,2)));
            confidence = freq/sum_freq;
        else
            confidence = 0;
        end
        topology_matrix{j,i} = confidence;
    end
end

% build topology freqency matrix
key = keys(anprMap);
topology_matrix = cell(length(key)+1,length(key)+1);
for i=1:length(key)
    camId = key{i};
    freq_matrix{1,i+1} = camId;
    freq_matrix{i+1,1} = camId;
end

% add value to frequency matrix
for i=2:length(key)+1
    camId_1 = freq_matrix{1,i};
    for j=2:length(key)+1
        camId_2 = freq_matrix{j,1};
        camConnection = [camId_1 ' ' camId_2];
        if isKey(refinedTopologyMap, camConnection)
            val = refinedTopologyMap(camConnection);
            [len,~] = size(val);
            for m=1:len
                num = val{m,1};
                if num==1
                    freq = val{m,2};
                end
            end
        else
            freq = 0;
        end
        freq_matrix{j,i} = freq;
    end
end

key = keys(journeyMap);
ct=1;
for i=1:length(key)
    val = journeyMap(key{i});
    [len,~] = size(val);
    for j=1:len
        cam = val{j}{2};
        if strcmp(cam, 'ANPR33.2')
            test{ct,1} = key{i};
            ct=ct+1;
        end
    end
end

key = keys(topologyMap_hop3);
for i=1:length(key)
    display(i);
    camConnection = key{i};
    subMap = topologyMap_hop3(camConnection);
    cams = keys(subMap);
    for j=1:length(cams)
        cam = cams{j};
        num = subMap(cam);
        new_array{j,1} = cam;
        new_array{j,2} = num;
    end
    topologyMap_hop3(camConnection) = new_array;
    clear new_array;
end



