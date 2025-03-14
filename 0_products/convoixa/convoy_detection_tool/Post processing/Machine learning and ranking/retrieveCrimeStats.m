function avgNum = retrieveCrimeStats(date, reads, crimeMap, anprMap, searchRadius)
[len,~] = size(reads);
ct = 0;
count = 0;
for i=1:2:len
    anprId = reads{i,3};
    [totalCrime] = checkCrimeStatsSingle(date, anprId, crimeMap, anprMap, searchRadius);
    if totalCrime>0
        count = count+1;
    end
    ct=ct+totalCrime;
end
avgNum = ct/count;
%display('Done');