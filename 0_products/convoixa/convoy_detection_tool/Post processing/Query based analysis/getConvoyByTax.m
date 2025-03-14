function [convoy, convoy_date] = getConvoyByTax(taxConvoyMap, tax1, tax2, date) 
t0 = 734139;
convoy = {};
convoy_date = {};
ct=1;
taxKey1 = [tax1 ' ' tax2];
taxKey2 = [tax2 ' ' tax1];
flag = strfind(date, '-');
day = date(1:flag(1)-1);
month = date(flag(1)+1:flag(2)-1);
year = date(flag(2)+1:end);
date_str = date2str(day, month, year);
flag_date = 0;
flag_tax = 0;

if isKey(taxConvoyMap, taxKey1)
    dateMap = taxConvoyMap(taxKey1);
    if isKey(dateMap, date_str)
        convoy_array = dateMap(date_str);
        for i=1:length(convoy_array)
            val = convoy_array{i};
            read = val{1};
            convoy{ct} = read;
            ct=ct+1;
        end
        flag_date = 1;
    else
        flag_date = 0;
    end
    flag_tax = 1;
else
    flag_tax = 0;
end

if isKey(taxConvoyMap, taxKey2)
    dateMap = taxConvoyMap(taxKey2);
    if isKey(dateMap, date_str)
        convoy_array = dateMap(date_str);
        for i=1:length(convoy_array)
            val = convoy_array{i};
            read = val{1};
            convoy{ct} = read;
            ct=ct+1;
        end
        flag_date = 1;
    else
        flag_date = 0;
    end
    flag_tax = 1;
else
    flag_tax = 0;
end

if flag_date ==0 
    disp('There is no record for the input date');
end
if flag_tax == 0;
    disp('There is no record for the input tax code');
end

if ~isempty(convoy)
    for i=1:length(convoy)
        read = convoy{i};
        [len,~] = size(read);
        for n=1:len
            datetime = read{n,2};
            time_str = datestr(t0+datetime/86400);
            read{n,2} = time_str;
        end
        convoy_date{i} = read;
    end
end
end