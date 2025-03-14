%Haiyue@2015
function output_date = dateConvert(input_date, in_format, out_format)
if strcmp(in_format,'dd-mm-yyyy') && strcmp(out_format, 'yyyy-mm-dd')
    tmp = strfind(input_date, '-');
    day = input_date(1:tmp(1)-1);
    month = input_date(tmp(1)+1:tmp(2)-1);
    year = input_date(tmp(2)+1:end);
    output_date = [year '-' month '-' day];
end
if strcmp(in_format, 'yyyy-mm-dd') && strcmp(out_format, 'dd-mm-yyyy')
    tmp = strfind(input_date, '-');
    year = input_date(1:tmp(1)-1);
    month = input_date(tmp(1)+1:tmp(2)-1);
    day = input_date(tmp(2)+1:end);
    output_date = [day '-' month '-' year];
end
end
