function [dayOfWeek] = retrieveTravelTime_v2(ANPR1, ANPR2, dir_path_1, date, anprMap)
dayOfWeek = [];
[~, dayName] = weekday(datenum(date,'dd-mm-yyyy'));
flag = strfind(date, '-');
day = date(1:flag(1)-1);
month = date(flag(1)+1:flag(2)-1);

val1 = anprMap(ANPR1);
if isfield(val1, 'relatedCams')
    cams1 = val1.relatedCams;
    cams1{length(cams1)+1} = ANPR1;
else
    cams1{1} = ANPR1;
end

val2 = anprMap(ANPR2);
if isfield(val2,'relatedCams')
    cams2 = val2.relatedCams;
    cams2{length(cams2)+1} = ANPR2;
else
    cams2{1} = ANPR2;
end


for i=1:length(cams1)
    anpr_tmp1 = cams1{i};
    for j=1:length(cams2)
        anpr_tmp2 = cams2{j};
        camConnection = [anpr_tmp1 ' ' anpr_tmp2];
        file_tmp = [dir_path_1 '\' dayName '\' camConnection '.mat'];
        if ~exist(file_tmp, 'file')
            disp('No historical record is found for these two ANPR cameras');
        else
            load(file_tmp);
            data = results;
            dayOfWeek = [dayOfWeek; data];
            clear data;
        end
    end
end

dayOfWeek = sortrows(dayOfWeek,1);

% 
% camConnection = [ANPR1 ' ' ANPR2];
% file_1 = [dir_path_1 '\' dayName '\' camConnection '.mat'];
% if ~exist(file_1, 'file')
%     display('No historical record is found for these two ANPR cameras');    
% else
%     load(file_1);
%     data = results;
%     dayOfWeek = sortrows(data,1);
%     clear data;
% end

