function timeNum = convertTimeStr(time)
tmp = strfind(time, ':');
timeNum = str2num(time(1:tmp(1)-1))*3600 + str2num(time(tmp(1)+1:tmp(2)-1))*60 + str2num(time(tmp(2)+1:end));
end