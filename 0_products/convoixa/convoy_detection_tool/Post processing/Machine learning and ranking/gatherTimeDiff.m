function timeDiffMap = gatherTimeDiff(map)
t0 = 734139;
timeDiffMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
keySet = keys(map);
for i=1:length(keySet)
    val = map(keySet{i});
    for j=1:length(val);
        reads = val{j}{1};
        time = reads{1,2};
        time_str = datestr(t0+time/86400);
        tmp = strfind(time_str, ' ');
        date = time_str(1:tmp(1)-1);
        flag = strfind(date, '-');
        day = date(1:flag(1)-1);
        month = date(flag(1)+1:flag(2)-1);
        year = date(flag(2)+1:end);
        date_str = date2str(day, month, year);
        [~, dayName] = weekday(datenum(date_str,'dd-mm-yyyy'));
        
        [len,~]=size(reads);
        for m=1:2:len
            cam = reads{m,3};
            flag = strfind(cam, 'ANPR');
            if ~isempty(flag)
                td = reads{m,11};
                if ~isKey(timeDiffMap,cam)
                    dayOfWeek = containers.Map('KeyType', 'char', 'ValueType', 'any');                    
                    data(1) = td;
                    dayOfWeek(dayName) = data;
                    timeDiffMap(cam) = dayOfWeek;
                    clear data;
                    clear dayOfWeek;
                else
                    dayOfWeek = timeDiffMap(cam);
                    if ~isKey(dayOfWeek, dayName)
                        data(1) = td;
                        dayOfWeek(dayName) = data;
                    else
                        data = dayOfWeek(dayName);
                        data(length(data)+1) = td;
                        dayOfWeek(dayName) = data;
                    end
                    timeDiffMap(cam) = dayOfWeek;
                    clear data;
                    clear dayOfWeek;
                end
            end
        end
        clear dayName;
    end
end
end