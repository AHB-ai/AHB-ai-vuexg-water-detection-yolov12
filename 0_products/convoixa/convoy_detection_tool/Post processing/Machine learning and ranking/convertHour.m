function timeNum = convertHour(timeStr, separator)
flag = strfind(timeStr, separator);
hour = str2num(timeStr(1:flag(1)-1));
min = str2num(timeStr(flag(1)+1:flag(2)-1));
sec = str2num(timeStr(flag(2)+1:end));
timeNum = hour*3600+min*60+sec;
end