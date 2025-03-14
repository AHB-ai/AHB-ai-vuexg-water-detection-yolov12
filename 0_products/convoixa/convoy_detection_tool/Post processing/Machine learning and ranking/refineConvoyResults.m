function new_map = refineConvoyResults(map, timeDiffMap)
new_map = containers.Map('KeyType', 'char', 'ValueType', 'any');
keySet = keys(map);
for i=1:length(keySet)
    val = map(keySet{i});
    for j=1:length(val);
        reads = val{j}{1};
        [len,~]=size(reads);
        ct=0;
        for m=1:2:len
            cam = reads{m,3};
            td = reads{m,11};
            if isKey(timeDiffMap,cam)
                data = timeDiffMap(cam);
                
                [~, bins] = histogram(data, 10);
%                 len = length(data);
%                 cutoffCounts = len*0.2;
%                 tempCount = 0;
%                 idx=50;
%                 while tempCount<cutoffCounts && idx>1
%                     tempCount = tempCount + counts(idx);
%                     idx=idx-1;
%                 end
                
                if length(data)>10
                    if td<=bins(3)
                        ct = ct+1;
                    end
                else
                    ct = ct+1;
                end
            else
                ct = ct+1;
            end
        end
        pectg = ct/(len/2);
        if pectg>0.95
        %if ct==len/2
            if ~isKey(new_map, keySet{i})
                info{1} = val{j};
                new_map(keySet{i}) = info;
                clear info;
            else
                info = new_map(keySet{i});
                info{length(info)+1} = val{j};
                new_map(keySet{i}) = info;
                clear info;
            end
        end
    end
end
end