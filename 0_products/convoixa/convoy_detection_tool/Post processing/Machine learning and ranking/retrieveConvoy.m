function convoy = retrieveConvoy(rankMat, idx, convoyMap)
t0 = 734139;
keyIdx = rankMat(idx, 10);
conIdx = rankMat(idx, 11);
key = keys(convoyMap);
val = convoyMap(key{keyIdx});
convoy = val{conIdx};
reads = convoy{1};
[len,~] = size(reads);
for n=1:len
    datetime = reads{n,2};
    time_str = datestr(t0+datetime/86400);
    reads{n,2} = time_str;
end
convoy{1} = reads;
end