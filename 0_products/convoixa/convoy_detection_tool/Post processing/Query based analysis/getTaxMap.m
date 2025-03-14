function taxConvoyMap = getTaxMap(map)
taxConvoyMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(map);
t0 = 734139;
for i=1:length(keySet)
    val = map(keySet{i});
    for j=1:length(val)
        data = val{j}{1};
        tax1 = data{1,7};
        tax2 = data{2,7};
        tax1(tax1==' ')='';
        tax2(tax2==' ')='';
        time = data{1,2};
        time_str = datestr(t0+time/86400);
        tp = strfind(time_str, ' ');
        date_str = time_str(1:tp(1)-1);
        taxKey = [tax1 ' ' tax2];
        if ~isKey(taxConvoyMap, taxKey)
            dateMap = containers.Map('KeyType','char','ValueType','any');
            content{1} = val{j};
            dateMap(date_str) = content;
            taxConvoyMap(taxKey) = dateMap;
            clear content;
            clear dateMap;
        else
            dateMap = taxConvoyMap(taxKey);
            if ~isKey(dateMap, date_str)
                content{1} = val{j};
                dateMap(date_str) = content;
                clear content;
            else
                content = dateMap(date_str);
                content{length(content)+1} = val{j};
                dateMap(date_str) = content;
                clear content;
            end
            taxConvoyMap(taxKey) = dateMap;
            clear dateMap;
        end
    end
end