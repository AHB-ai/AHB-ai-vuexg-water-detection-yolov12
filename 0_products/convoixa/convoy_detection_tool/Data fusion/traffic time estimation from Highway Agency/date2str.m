% Haiyue@2015
function date_str = date2str(day, month, year)

switch month
    case '01'
        month_str = 'Jan';
    case '02'
        month_str = 'Feb';
    case '03' 
        month_str = 'Mar';
    case '04'
        month_str = 'Apr';
    case '05'
        month_str = 'May';
    case '06'
        month_str = 'Jun';
    case '07'
        month_str = 'Jul';
    case '08'
        month_str = 'Aug';
    case '09'
        month_str = 'Sep';
    case '10'
        month_str = 'Oct';
    case '11'
        month_str = 'Nov';
    case '12'
        month_str = 'Dec';
    
    case 'JAN'
        month_str = 'Jan';
    case 'FEB'
        month_str = 'Feb';
    case 'MAR' 
        month_str = 'Mar';
    case 'APR'
        month_str = 'Apr';
    case 'MAY'
        month_str = 'May';
    case 'JUN'
        month_str = 'Jun';
    case 'JUL'
        month_str = 'Jul';
    case 'AUG'
        month_str = 'Aug';
    case 'SEP'
        month_str = 'Sep';
    case 'OCT'
        month_str = 'Oct';
    case 'NOV'
        month_str = 'Nov';
    case 'DEC'
        month_str = 'Dec';
end

tmp = strfind(year, ' ');

if isempty(tmp)
    year_str = year;
end

if ~isempty(tmp)
    year_str = year(1:(tmp-1));
    year_str = ['20' year_str];
end
        
date_str = [day '-' month_str '-' year_str];

        


