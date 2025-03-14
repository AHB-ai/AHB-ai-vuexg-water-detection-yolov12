function timeNum = getTimeNum(time, t0)
date_time_str = datestr(t0+time/86400);
tmp = strfind(date_time_str, ' ');
if isempty(tmp)
    timeNum = 0;
else
    date_str = date_time_str(1:tmp(1)-1);
    dateNum = datenum(date_str, 'dd-mm-yyyy')-t0;
    timeNum = time-(dateNum*24*3600);
end
end