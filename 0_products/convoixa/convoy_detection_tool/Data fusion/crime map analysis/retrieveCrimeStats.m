function ct = retrieveCrimeStats(reads, crimeMap, anprMap, searchRadius)
[len,~] = size(reads);
ct = 0;
for i=1:len
    timeNum = reads{i,2};
    anprId = reads{i,3};
    timeStr = convertTime(timeNum);
    flag = strfind(timeStr, ' ');
    dateStr = timeStr(1:flag(1)-1);
    temp = str2date(dateStr);
    flag = strfind(temp, '-');
    date = [temp(flag(2)+1:end) '-' temp(flag(1)+1:flag(2)-1)];
    [totalCrime] = checkCrimeStatsSingle(date, anprId, crimeMap, anprMap, searchRadius);
    ct=ct+totalCrime;
end
disp('Done');