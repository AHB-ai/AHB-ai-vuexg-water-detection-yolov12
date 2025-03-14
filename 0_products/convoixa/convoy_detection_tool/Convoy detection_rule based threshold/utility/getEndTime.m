function [date, timeNum] = getEndTime(input)
datetime = input{length(input),2};
tp = strfind(datetime, ' ');
date = datetime(1:tp(1)-1);
time = datetime(tp(1)+1:end);
sectmp = str2num(strrep(time,':', ' '));
timeNum = sectmp(1)*3600+sectmp(2)*60+sectmp(3);
end