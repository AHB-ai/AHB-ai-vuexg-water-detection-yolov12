function sessionSizeMap_v3 = extractSessionSize(anprMap, path, perct)
sessionSizeMap_v3 = containers.Map('KeyType','char','ValueType','any');
fileList = getAllFiles(path);
keySet = keys(anprMap);
for j=1:length(keySet)
    camID = keySet{j};     
    data = [];
    for i=1:length(fileList)
        file = fileList{i};
        load(file);
        if isKey(sessionSizeMap, camID)
            tmpData = sessionSizeMap(camID);
            data = [data,tmpData];
        end
        clear sessionSizeMap;
    end
    cutoffpoint = length(data)*perct;
    [frequency, bins] = histogram(data, 1000);
    
    count = 0;
    for m = 1:length(bins)
        if count>=cutoffpoint && bins(m)>2
            size = bins(m);
            break;
        else
            count = frequency(m);
            count = count+count;
        end
    end
%     count = 0;
%     for m=1:length(frequency)        
%         if count>=cutoffpoint
%             size = bins(m);
%             break;
%         else
%             count = frequency(m);
%             count = count+count;
%         end               
%     end
    %size = bins(2);
    display(camID);
    display(size);
    disp('----------------');
    sessionSizeMap_v3(camID) = size;
end
