%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%% 
function outputMultipleConvoy(iopath, input)
t0 = 734139;
output = input;
% To exclude repeated sessions 
keySet = keys(output);
for j=1:length(keySet)
    key = keySet{j};
    val = output(key);
    for m=1:length(val)
        content = val{m};
        if ~isempty(content)
            array_1 = content{2}(:,1);
            array_2 = content{2}(:,2);
            array_3 = content{2}(:,3);
            for i=1:length(keySet)
                if i~=j
                    key_cmp = keySet{i};
                    val_cmp = output(key_cmp);
                    if ~isempty(val_cmp)
                        for n=1:length(val_cmp)
                            content_cmp = val_cmp{n};
                            if ~isempty(content_cmp)
                                array_1_cmp = content_cmp{2}(:,1);
                                array_2_cmp = content_cmp{2}(:,2);
                                array_3_cmp = content_cmp{2}(:,3);
                                df1 = setdiff(array_1,array_1_cmp);
                                df2 = setdiff(array_2,array_2_cmp);
                                df3 = setdiff(array_3,array_3_cmp);
                                if isempty(df1) && isempty(df2) && isempty(df3)
                                    val_cmp{n} = {};
                                end
                            end
                        end
                        output(key_cmp) = val_cmp;
                    end
                end
            end
        end
    end
end

% Output results in CSV format
keySet = keys(output);
for idx=1:length(keySet)
    ct=1;
    key = keySet{idx};
    val = output(key);
    for j=1:length(val)
        content = val{j};
        if ~isempty(content)
            temp = val{j}{2};
            [height, ~] = size(temp);
            for n=1:height
                datetime = temp{n,2};
                tp = strfind(datetime, ' ');
                date = datetime(1:tp(1)-1);
                time = datetime(tp(1)+1:end);
                sectmp = str2num(strrep(time,':', ' '));
                timeNum = sectmp(1)*3600+sectmp(2)*60+sectmp(3);
                dateNum = datenum(date, 'dd-mm-yyyy')-t0;
                realtime = dateNum*24*3600+timeNum;
                temp{n,2} = realtime;
            end
            for n=1:height
                realtime = temp{n,2};
                real_time_str = datestr(t0+realtime/86400);
                temp{n,2} = real_time_str;
            end
            for n=1:height
                pair_write(ct,:) = temp(n,:);
                ct=ct+1;
            end
            ct=ct+1;
        end
    end
    if exist('pair_write', 'var')
        file = [iopath '\' key '.csv'];
        simplemat2csv(pair_write, file);
        clear pair_write;
        clear ct;
    end
end

end