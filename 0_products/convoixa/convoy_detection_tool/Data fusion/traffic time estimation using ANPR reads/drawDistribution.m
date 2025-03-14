function drawDistribution(ANPR1, ANPR2, dir_path, search_window, timestr)
camConnection = [ANPR1 ' ' ANPR2];
file = [dir_path '\' camConnection '.mat'];
if ~exist(file, 'file')
    disp('No record is found for these two ANPR cameras');    
else
    tmp = load(file);
    data = tmp.data;
    [len,~] = size(data);
    if len>100
        time = convertTimeStr(timestr);        
        lower_bound = time-search_window;
        upper_bound = time+search_window;
        [lower_index, upper_index] = binarySearch(data, lower_bound, upper_bound);
        output = data(lower_index:upper_index,2);
        if length(output)>50
            histogram(output, 20);
            %hist(output,20);
%             figure('Name', 'Gaussian');
%             histfit(output, 10 ,'normal');
%             figure('Name', 'Inverse Gaussian');
%             histfit(output, 10 ,'inverse gaussian');
%             figure('Name', 'Exponential');
%             histfit(output, 10 ,'exponential');
        else
            disp('Data size is too small to have meaningful distribution !');
        end
    else
        disp('Data size is too small to have meaningful distribution !');
    end
end
end