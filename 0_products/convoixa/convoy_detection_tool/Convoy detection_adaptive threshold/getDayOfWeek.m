function day = getDayOfWeek(timeNum)
t0 = 734139;
timeStr = datetime(t0+timeNum/86400);
flag = strfind(timeStr, ' ');
date = timeStr(1:flag(1)-1);
[~, tp] = weekday(datetime(date,'dd-mm-yyyy'));
switch tp
    case 'Mon'
        day = 'weekday';
    case 'Tue'
        day = 'weekday';
    case 'Wed'
        day = 'weekday';
    case 'Thu'
        day = 'weekday';
    case 'Fri'
        day = 'weekday';
    case 'Sat'
        day = 'weekend';
    case 'Sun'
        day = 'weekend';
end
end