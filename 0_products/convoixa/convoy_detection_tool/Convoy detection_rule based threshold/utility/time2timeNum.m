
function timeNum = time2timeNum(timestr)
try
    sectmp = str2num(strrep(timestr,':', ' '));
    timeNum =  sectmp(1)*3600+sectmp(2)*60+sectmp(3);    
catch
end