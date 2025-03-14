%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%% 
function outputRepeatedConvoyCSV(iopath, input)
t0 = 734139;
keySet = keys(input);

for i=1:length(keySet)
    key = keySet{i};
    val = input(key);
    temp = val.convoys;
    ct=1;
    for j=1:length(temp)
        convoy = temp{j}{1};
        [len,~] = size(convoy);
        for n=1:len
            datetime = convoy{n,2};
            time_str = datestr(t0+datetime/86400);
            convoy{n,2} = time_str;
        end
        for m=1:len
            pair_write(ct,:) = convoy(m,:);
            ct=ct+1;
        end
        ct=ct+1;
    end
    file = [iopath '\' key '.csv'];
    simplemat2csv(pair_write, file);
    clear pair_write;
    clear ct;
end

