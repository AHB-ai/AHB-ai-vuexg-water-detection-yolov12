function drawDistribution_v2(ANPR1, ANPR2, dir_path, search_window, date, timestr)
[daynumber, ~] = weekday(datetime(date,'dd-mm-yyyy'));
tag = distributeDay(daynumber);

camConnection = [ANPR1 ' ' ANPR2];
file = [dir_path '\' tag '\' camConnection '.mat'];
if ~exist(file, 'file')
    disp('No record is found for these two ANPR cameras');    
else
    tmp = load(file);
    data = tmp.results;
    [len,~] = size(data);
    data = sortrows(data,1);
    if len>100
        time = convertTimeStr(timestr);        
        lower_bound = time-search_window;
        upper_bound = time+search_window;
        [lower_index, upper_index] = binarySearch(data, lower_bound, upper_bound);
        output = data(lower_index:upper_index,2);        
        if length(output)>50
            histogram(output, 20);
        else
            disp('Data size is too small to have meaningful distribution !');
        end
    else
        disp('Data size is too small to have meaningful distribution !');
    end
end

function tag = distributeDay(daynumber)
switch daynumber
    case 1
        tag = 'weekend';
    case 2
        tag = 'weekdays';
    case 3
        tag = 'weekdays';
    case 4
        tag = 'weekdays';
    case 5
        tag = 'weekdays';
    case 6
        tag = 'weekdays';
    case 7
        tag = 'weekend';
end