%dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\between camera topology\automate\output';
%topologyStatsMap = containers.Map('KeyType','char','ValueType','any');

function analyseTopology(camConnectMap, date, output_folder)
topologyStatsMap = containers.Map('KeyType','char','ValueType','any');
if ~exist(output_folder, 'file')
    mkdir(output_folder);
end
% if ~exist(output, 'file')
%     mkdir(output);
% end
% fileList = getAllFiles(dir_path);
% for i=1:length(fileList)
%     file = fileList{i};
%     load(file);
keySet = keys(camConnectMap);
for j=1:length(keySet)
    display(j);
    vrm = keySet{j};
    subMap = camConnectMap(vrm);
    keyMap = keys(subMap);
    for m=1:length(keyMap)
        camConnection = keyMap{m};
        stats = subMap(camConnection);
        for n=1:length(stats)
            val = stats{n};
            num_hop = num2str(val{1});
            cam_array = val{2};
            if ~isKey(topologyStatsMap, camConnection)
                miniMap = containers.Map('KeyType','char','ValueType','any');
                metadata{1} = {cam_array, vrm};
                miniMap(num_hop) = {1, metadata};
                topologyStatsMap(camConnection) = miniMap;
                clear miniMap;
            else
                miniMap = topologyStatsMap(camConnection);
                if ~isKey(miniMap, num_hop)
                    metadata{1} = {cam_array, vrm};
                    miniMap(num_hop) = {1, metadata};
                else
                    temp=miniMap(num_hop);
                    ct = temp{1,1};
                    metadata = temp{1,2};
                    ct=ct+1;
                    metadata{length(metadata)+1} = {cam_array, vrm};
                    miniMap(num_hop)={ct, metadata};
                    clear ct;
                    clear metadata;
                end
                topologyStatsMap(camConnection) = miniMap;
                clear miniMap;
            end
        end
    end
    %     end
    % end
end
save([output_folder '\' date '_topology.mat'],'topologyStatsMap');
