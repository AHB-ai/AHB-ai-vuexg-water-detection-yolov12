ttMap = containers.Map('KeyType','char','ValueType','any');
[height, width] = size(traffic_matrix);
for i=2:width
    tmp_cam = traffic_matrix(1,i);
    camId_1 = tmp_cam{1};
    clear tmp_cam;
    for j=2:height
        tmp_cam = traffic_matrix(j,1);
        camId_2 = tmp_cam{1};        
        trafficFile = traffic_matrix(j,i);
        if ~isempty(trafficFile{1})
            load(trafficFile{1});
            stats.std = std(results(:,2));
            stats.mean = mean(results(:,2));
            stats.min = min(results(:,2));
            stats.max = max(results(:,2));
            temp = topology_matrix(j,i);
            stats.confidence = temp{1};
            camConnection = [camId_1 ' ' camId_2];
            ttMap(camConnection) = stats;
        end
    end
end


