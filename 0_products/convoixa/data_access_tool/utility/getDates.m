% This script is to get all dates between two given dates
% Haiyue@May 2015
function dateList = getDates(date_start, date_end)
date_start = dateConvert(date_start,'dd-mm-yyyy','yyyy-mm-dd');
date_end = dateConvert(date_end,'dd-mm-yyyy','yyyy-mm-dd');
tmpList = cellstr(datestr(datenum(date_start)+1:datenum(date_end),'yyyy-mm-dd'));
dateList = cell(1, length(tmpList));
tmpdate= dateConvert(date_start,'yyyy-mm-dd','dd-mm-yyyy');
flag = strfind(tmpdate, '-');
day = tmpdate(1:flag(1)-1);
month = tmpdate(flag(1)+1:flag(2)-1);
year = tmpdate(flag(2)+1:end);
date_str = date2str(day, month, year);
dateList{1}  = date_str;
for i=1:length(tmpList)
    if ~isempty(tmpList{i})
        tmpdate = dateConvert(tmpList{i},'yyyy-mm-dd','dd-mm-yyyy');
        flag = strfind(tmpdate, '-');
        day = tmpdate(1:flag(1)-1);
        month = tmpdate(flag(1)+1:flag(2)-1);
        year = tmpdate(flag(2)+1:end);
        date_str = date2str(day, month, year);
        dateList{i+1} = date_str;
    end
end