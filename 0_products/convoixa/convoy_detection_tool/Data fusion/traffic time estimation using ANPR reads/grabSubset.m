function [data1, data2] = grabSubset(dayOfWeek, dayOfMonth, timestr, search_window)
data1 = [];
data2 = [];
time = convertTimeStr(timestr);
lower_bound = time-search_window;
upper_bound = time+search_window;
if ~isempty(dayOfWeek)
    [lower_index, upper_index] = binarySearch(dayOfWeek, lower_bound, upper_bound);
    data1 = dayOfWeek(lower_index:upper_index,2);
    clear lower_index;
    clear upper_index;
end
if ~isempty(dayOfMonth)
    [lower_index, upper_index] = binarySearch(dayOfMonth, lower_bound, upper_bound);
    data2 = dayOfMonth(lower_index:upper_index,2);
    clear lower_index;
    clear upper_index;
end
end