function new_map = refineConvoyResults_v2(map, timeDiffMap)
t0 = 734139;
new_map = containers.Map('KeyType', 'char', 'ValueType', 'any');
keySet = keys(map);
for i=1:length(keySet)
    val = map(keySet{i});
    for j=1:length(val);
        reads = val{j}{1};
        
        time = reads{1,2};
        time_str = datetime(t0+time/86400);
        tmp = strfind(time_str, ' ');
        date = time_str(1:tmp(1)-1);
        flag = strfind(date, '-');
        day = date(1:flag(1)-1);
        month = date(flag(1)+1:flag(2)-1);
        year = date(flag(2)+1:end);
        date_str = date2str(day, month, year);
        [~, dayName] = weekday(datetime(date_str,'dd-mm-yyyy'));
        
        [len,~]=size(reads);
        ct=0;
        for m=1:2:len
            cam = reads{m,3};
            td = reads{m,11};
            if isKey(timeDiffMap,cam)
                subMap = timeDiffMap(cam);
                data = subMap(dayName);
                [~, bins] = histogram(data, 10);                
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
        if pectg>0.9
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