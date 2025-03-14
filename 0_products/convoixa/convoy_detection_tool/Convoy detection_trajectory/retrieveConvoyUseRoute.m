% map = processedConvoyMap_doubleVRM
function [convoy] = retrieveConvoyUseRoute(map, anpr_routes, date, similarity)

t0 = 734139;
count = 1;
keySet = keys(map);
convoy = {};
flag = strfind(date, '-');
if ~isempty(flag)
    day = date(1:flag(1)-1);
    month = date(flag(1)+1:flag(2)-1);
    year = date(flag(2)+1:end);
    input_date = date2str(day, month, year);
else
    input_date = date;
end

tmp = strfind(anpr_routes, ' ');
for i=1:length(tmp)+1
    if i==1
        anpr = anpr_routes(1:tmp(1)-1);
    elseif i==length(tmp)+1
        anpr = anpr_routes(tmp(length(tmp))+1:end);
    else
        anpr = anpr_routes(tmp(i-1)+1:tmp(i)-1);
    end
    group_anpr{i} = anpr;
end

if strcmp(input_date, 'all')
    for i=1:length(keySet)
        val = map(keySet{i});
        for j=1:length(val)
            data = val{j}{1};
            group_anpr_tmp = data(:,3);
            ct=1;
            for m=1:2:length(group_anpr_tmp)
                group_anpr_cmp{ct} = group_anpr_tmp{m};
                ct=ct+1;
            end
            time = data{1,2};
            time_str = datestr(t0+time/86400);
            tp = strfind(time_str, ' ');
            date_str = time_str(1:tp(1)-1);
            anprDif = setxor(group_anpr, group_anpr_cmp);
            prctg = length(anprDif)/length(group_anpr_cmp);
            if (1-prctg)>=similarity
                convoy{count} = data;
                count = count+1;
            end
            clear data;
            clear group_anpr_tmp;
            clear group_anpr_cmp;
            clear time;
            clear date_str;
            clear prctg;
            clear anprDif;
        end
    end
else
    for i=1:length(keySet)
        val = map(keySet{i});
        for j=1:length(val)
            data = val{j}{1};
            group_anpr_tmp = data(:,3);
            ct=1;
            for m=1:2:length(group_anpr_tmp)
                group_anpr_cmp{ct} = group_anpr_tmp{m};
                ct=ct+1;
            end
            time = data{1,2};
            time_str = datestr(t0+time/86400);
            tp = strfind(time_str, ' ');
            date_str = time_str(1:tp(1)-1);
            if strcmp(input_date,date_str)
                anprDif = setxor(group_anpr, group_anpr_cmp);
                prctg = length(anprDif)/length(group_anpr_cmp);
                if (1-prctg)>=confidence
                    convoy{count} = data;
                    count = count+1;
                end
            end
            clear data;
            clear group_anpr_tmp;
            clear group_anpr_cmp;
            clear time;
            clear date_str;
            clear prctg;
            clear anprDif;
        end
    end
end

if ~isempty(convoy)
    for i=1:length(convoy)
        read = convoy{i};
        [len,~] = size(read);
        for n=1:len
            datetime = read{n,2};
            time_str = datestr(t0+datetime/86400);
            read{n,2} = time_str;
        end
        convoy{i} = read;
    end
end

