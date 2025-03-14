% map = processedConvoyMap_doubleVRM
function partialRouteMap  = getConvoyWithPartialRoutes(map)

t0 = 734139;
tempList = {};
count = 1;
keySet = keys(map);
for i=1:length(keySet)
    val = map(keySet{i});
    for j=1:length(val)
        data = val{j}{1};
        group_anpr = data(:,3);
        time = data{1,2};
        time_str = datestr(t0+time/86400);
        tp = strfind(time_str, ' ');
        date_str = time_str(1:tp(1)-1);
        tempList{count} = {group_anpr,date_str,i,j};
        count = count+1;
    end
end

associateList = cell(length(tempList),1);
for m=1:length(tempList)
    display(m);
    data = tempList{m};
    group_anpr = data{1};
    for n=1:length(tempList)
        if m~=n
            data_cmp = tempList{n};
            group_anpr_cmp = data_cmp{1};
            len_cmp = length(group_anpr_cmp);
            len = length(group_anpr);
            if len_cmp<len
                if ismember(group_anpr_cmp, group_anpr)
                    if isempty(associateList{m})
                        tmpdata{1} = data_cmp;
                        associateList{m} = tmpdata;
                        clear tmpdata;
                    else
                        tmpdata = associateList{m};
                        tmpdata{length(tmpdata)+1} = data_cmp;
                        associateList{m} = tmpdata;
                        clear tmpdata;
                    end
                end
            end
        end
    end
end

formatIn = 'dd-mmm-yyyy';
tempMap = containers.Map('KeyType','char','ValueType','any');
for i=1:length(associateList)
    convoys = associateList{i};
    data_o = tempList{i};
    group_anpr = data_o{1};
    date = data_o{2};
    date_num = datenum(date,formatIn);
    if ~isempty(convoys)
        for m=1:length(convoys)
            data1 = convoys{m};
            group_anpr1 = data1{1};
            date1 = data1{2};
            date_num1 = datenum(date1,formatIn);
            if date_num1>date_num
                for n=m+1:length(convoys)
                    data2 = convoys{n};
                    group_anpr2 = data2{1};
                    date2 = data2{2};
                    date_num2 = datenum(date2,formatIn);
                    if date_num1==date_num2
                        if ismember(group_anpr1, group_anpr)
                            if ismember(group_anpr2, group_anpr)
                                if ~ismember(group_anpr1,group_anpr2)
                                    if (length(group_anpr1)+length(group_anpr2))<=length(group_anpr)
                                        anprStr = convert2str(group_anpr);
                                        if ~isKey(tempMap, anprStr)
                                            info{1} = {i,m,n};
                                            tempMap(anprStr) = info;
                                            clear info;
                                        else
                                            info = tempMap(anprStr);
                                            info{length(info)+1} = {i,m,n};
                                            tempMap(anprStr) = info;
                                            clear info;
                                        end
                                    end
                                end
                            end
                        end
                    end
                    clear group_anpr2;
                end
            end
            clear group_anpr1;
        end
    end
end

partialRouteMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(tempMap);
if ~isempty(keySet)
    for i=1:length(keySet)
        val = tempMap(keySet{i});
        for j=1:length(val)
            indexList = val{j};
            a = indexList{1};
            b = indexList{2};
            c = indexList{3};
            convoy_o = tempList{a};
            read_o = getANPR(convoy_o,map);
            convoys = associateList{a};
            convoy1 = convoys{b};
            read1 = getANPR(convoy1,map);
            convoy2 = convoys{c};
            read2 = getANPR(convoy2,map);
            if ~isKey(partialRouteMap, keySet{i})
                content{1} = {read_o,read1,read2};
                partialRouteMap(keySet{i}) = content;
                clear content;
            else
                content = partialRouteMap(keySet{i});
                content{length(content)+1} = {read_o,read1,read2};
                partialRouteMap(keySet{i}) = content;
                clear content;
            end
        end
    end
end

    
