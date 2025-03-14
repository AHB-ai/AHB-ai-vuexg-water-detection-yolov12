function [data] = grabSubsetByDayOfWeek(dayOfWeek, timestr, search_window)
data = [];
time = convertTimeStr(timestr);
lower_bound = time-search_window;
upper_bound = time+search_window;
if ~isempty(dayOfWeek)
    [lower_index, upper_index] = binarySearch(dayOfWeek, lower_bound, upper_bound);
    data = dayOfWeek(lower_index:upper_index,2);
    clear lower_index;
    clear upper_index;
end
end