%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%% 
function outputConvoyCSV(iopath, input)
t0 = 734139;
keySet = keys(input);
for j=1:length(keySet)
    key = keySet{j};
    dataset = input(key);
    ct=1;
    for i=1:length(dataset)
        temp = dataset{i};
        val = temp{1};
        %stats = temp{2};
        [height, ~] = size(val);
        for n=1:height
            datetime = val{n,2};
            real_time_str = datestr(t0+datetime/86400);           
            val{n,2} = real_time_str;
        end       
        for n=1:height
            pair_write(ct,:) = val(n,:);
            ct=ct+1;
        end
        ct=ct+1;
    end
    file = [iopath '\' key '.csv'];
    simplemat2csv(pair_write, file);
    clear pair_write;
    clear ct;
end
end