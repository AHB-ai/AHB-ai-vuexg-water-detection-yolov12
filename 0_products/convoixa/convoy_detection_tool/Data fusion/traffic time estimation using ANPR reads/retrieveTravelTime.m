function [dayOfWeek, dayOfMonth] = retrieveTravelTime(ANPR1, ANPR2, dir_path_1, dir_path_2, date, all_month)
dayOfWeek = [];
dayOfMonth = [];

[~, dayName] = weekday(datenum(date,'dd-mm-yyyy'));
flag = strfind(date, '-');
day = date(1:flag(1)-1);
month = date(flag(1)+1:flag(2)-1);
camConnection = [ANPR1 ' ' ANPR2];

file_1 = [dir_path_1 '\' dayName '\' camConnection '.mat'];
if ~exist(file_1, 'file')
    disp('No historical record is found for these two ANPR cameras');    
else
    load(file_1);
    data = results;
    dayOfWeek = sortrows(data,1);
    clear data;
end

if strcmp(all_month, 'no')
    file_2 = [dir_path_2 '\' day '\' month '\' camConnection '.mat'];
    if ~exist(file_2, 'file')
        disp('No historical record is found for these two ANPR cameras at this date');
    else
        load(file_2);
        data = results;
        dayOfMonth = sortrows(data,1);
        clear data;
    end
end
if strcmp(all_month, 'yes')
    file_path = [dir_path_2 '\' day];
    subFolders=ListSubfolders(file_path);
    data = [];
    for i=1:length(subFolders)
        subfold = subFolders{i};
        file = [file_path '\' subfold '\' camConnection '.mat'];
        load(file);
        data = [data; results];
        dayOfMonth = sortrows(data,1);
    end
end
