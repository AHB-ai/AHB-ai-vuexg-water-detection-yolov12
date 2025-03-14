function [timeNum] = getTime(timestamp, t0)
tp = strfind(timestamp, ' ');
date = timestamp(1:tp(1)-1);
dateNum = datenum(date, 'dd-mm-yyyy')-t0;
time = timestamp(tp(1)+1:end);
sectmp = str2num(strrep(time,':', ' '));
timeNum = dateNum*24*3600+sectmp(1)*3600+sectmp(2)*60+sectmp(3);
end

