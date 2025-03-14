% Haiyue@Aug 2015
% dir_path ='C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\output_v2';
% search_window = 1800;
function [minVal, maxVal] = adapativeSessionBreak_v2(camConnection, dir_path, time, session_window, perct)
file = [dir_path '\' camConnection '.mat'];
if ~exist(file, 'file')
    minVal = 0;
    maxVal = 0;
else
    tmp = load(file);
    data = tmp.data;
    % An adaptive parameter for session break
    [len,~] = size(data);
    if len>100
        lower_bound = time-session_window;
        upper_bound = time+session_window;
        [lower_index, upper_index] = binarySearch(data, lower_bound, upper_bound);
        output = data(lower_index:upper_index,2);
        if length(output)>100
            [counts, bins] = histogram(output, 20);            
            len = length(output);
            cutoffCounts = len*perct;            
            tempCount = 0;
            j=20;
            while tempCount<cutoffCounts && j>1
                tempCount = tempCount + counts(j);
                j=j-1;
            end
            maxVal = bins(j);
            minVal = min(output);
        else
            minVal = 0;
            maxVal = 0;
        end
    else
        minVal = 0;
        maxVal = 0;
    end
end

