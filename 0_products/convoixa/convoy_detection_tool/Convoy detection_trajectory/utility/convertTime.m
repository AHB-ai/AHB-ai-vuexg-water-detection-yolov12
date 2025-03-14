% Haiyue@Feb 2015
function time = convertTime(data, idx)
datestr = data{idx,2};
try
    dateNum = datenum(datestr, 'dd-mm-yyyy')-734139;
    sectmp = str2num(strrep(data{idx,3},':', ' '));
    time =  dateNum*24*3600+sectmp(1)*3600+sectmp(2)*60+sectmp(3);    
catch
end