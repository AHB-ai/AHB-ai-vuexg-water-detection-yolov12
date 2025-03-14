% Haiyue@March 2015
function date_str = date2str2(day, month, year)

switch month
    case 'Jan'
        month_str = '01';
    case 'Feb'
        month_str = '02';
    case 'Mar' 
        month_str = '03';
    case 'Apr'
        month_str = '04';
    case 'May'
        month_str = '05';
    case 'Jun'
        month_str = '06';
    case 'Jul'
        month_str = '07';
    case 'Aug'
        month_str = '08';
    case 'Sep'
        month_str = '09';
    case 'Oct'
        month_str = '10';
    case 'Nov'
        month_str = '11';
    case 'Dec'
        month_str = '12';
            
    case 'JAN'
        month_str = '01';
    case 'FEB'
        month_str = '02';
    case 'MAR' 
        month_str = '03';
    case 'APR'
        month_str = '04';
    case 'MAY'
        month_str = '05';
    case 'JUN'
        month_str = '06';
    case 'JUL'
        month_str = '07';
    case 'AUG'
        month_str = '08';
    case 'SEP'
        month_str = '09';
    case 'OCT'
        month_str = '10';
    case 'NOV'
        month_str = '11';
    case 'DEC'
        month_str = '12';
end

tmp = strfind(year, ' ');

if isempty(tmp)
    if length(year)==2
        year_str = ['20' year];
    end
    if length(year)==4
        year_str = year;
    end
end

if ~isempty(tmp)
    year_str = year(1:(tmp-1));
    year_str = ['20' year_str];
end
        
date_str = [day '-' month_str '-' year_str];

        


