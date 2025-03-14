function [sameDirection, diffDirection, smallDataSize] = checkDirection(input_dir, threshold)
sameDirection = containers.Map('KeyType','char','ValueType','any');
diffDirection = containers.Map('KeyType','char','ValueType','any');
smallDataSize = containers.Map('KeyType','char','ValueType','any');

fileList = getAllFiles(input_dir);
for i=1:length(fileList)
    file = fileList{i};    
    load(file);
    keySet = keys(conMap);
    for j=1:length(keySet)
        key = keySet{j};
        val = conMap(key);
        if ~isempty(val)
            locs = val{1};
            bins = val{2};
            if length(locs)>1
                if ~isKey(diffDirection,key)
                    data{1} = val;
                    diffDirection(key) = data;
                    clear data;
                else
                    data = diffDirection(key);
                    data{length(data)+1} = val;
                    diffDirection(key) = data;
                    clear data;
                end
            else
                idx = locs;
                t = bins(idx);
                if t>threshold
                    if ~isKey(diffDirection,key)
                        data{1} = val;
                        diffDirection(key) = data;
                        clear data;
                    else
                        data = diffDirection(key);
                        data{length(data)+1} = val;
                        diffDirection(key) = data;
                        clear data;
                    end
                else
                    if ~isKey(sameDirection,key)
                        data{1} = val;
                        sameDirection(key) = data;
                        clear data;
                    else
                        data = sameDirection(key);
                        data{length(data)+1} = val;
                        sameDirection(key) = data;
                        clear data;
                    end
                end
            end
        else
            if ~isKey(smallDataSize,key)
                data{1} = val;
                smallDataSize(key) = data;
                clear data;
            else
                data = smallDataSize(key);
                data{length(data)+1} = val;
                smallDataSize(key) = data;
                clear data;
            end
        end
    end
end
end