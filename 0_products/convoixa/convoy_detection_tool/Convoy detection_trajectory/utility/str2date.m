%Haiyue@2015
function date = str2date(date_str)

tmp = strfind(date_str, '-');
day = date_str(1:(tmp(1)-1));
month_str = date_str((tmp(1)+1):(tmp(2)-1));
year = date_str((tmp(2)+1):end);

switch month_str
    case 'Jan'
        month = '01';
    case 'Feb'
        month = '02';
    case 'Mar' 
        month = '03';
    case 'Apr'
        month = '04';
    case 'May'
        month = '05';
    case 'Jun'
        month = '06';
    case 'Jul'
        month = '07';
    case 'Aug'
        month = '08';
    case 'Sep'
        month = '09';
    case 'Oct'
        month = '10';
    case 'Nov'
        month = '11';
    case 'Dec'
        month = '12';
end

date = [day '-' month '-' year];



