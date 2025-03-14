
function [matrix] = generateFeatures(map, anprMap, dir_path)
ct=1;
keySet = keys(map);
matrix = zeros(length(keySet),15);
for i=1:length(map)
    val = map(keySet{i});
    for j=1:length(val)
        stats = val{j}{2};
        convoy = val{j}{1};
        [dis_time_stats, total_distance] = retrieveDistance(convoy, anprMap, dir_path);
        delta_t_array = stats(:,2);
        % column 1 is standard deviation of absolute value of time difference/the mean value of absolute time difference
        matrix(ct,1) = std(abs(stats(:,2)))./mean(abs(stats(:,2)));
        % column 2 is standard deviation of number of vehicles in between/the mean value of number of vehicles in between
        matrix(ct,2) = std(abs(stats(:,3)))./mean(abs(stats(:,4)));
        % column 3 is standard deviation of absolute value of time difference
        matrix(ct,3) = std(abs(stats(:,2)));
%         % column 4 is the mean value of time difference
%         matrix(ct,4) = mean(stats(:,2));
        % column 4 is the mean value of absolute time difference
        matrix(ct,4) = mean(abs(stats(:,2)));
        % column 5 is standard deviation of number of vehicles in between
        matrix(ct,5) = std(stats(:,3));
        % column 6 is the mean value of number of vehicles in between
        matrix(ct,6) = mean(stats(:,3));
        % column 7 is number of change order/length of convoy session
        matrix(ct,7) = stats(2,4)/length(delta_t_array);
%         % column 6 is the dynamic range of number of vehicle in between
%         matrix(ct,6) = (max(stats(:,3)-min(stats(:,3))));
        % column 8 is the duration of the convoy session
        matrix(ct,8) = stats(4,4);
        % column 9 is the number of different cameras within the convoy session
        matrix(ct,9) = stats(5,4);
        % column 10 is the number of times this vehicle has been captured
        % within this convoy session
        [len,~] = size(stats);
        matrix(ct,10) = len;
        % column 10 is the mean value of estimated speed
        matrix(ct,11) = mean(dis_time_stats(:,3));
        % column 11 is the standard deviation of estimated speed
        matrix(ct,12) = std(dis_time_stats(:,3));
        % column 12 is the standard deviation of estimated speed
        matrix(ct,13) = total_distance;%std(dis_time_stats(:,3));
        % column 13 and 14 record the index       
        matrix(ct,14) = i;
        matrix(ct,15) = j;
        ct=ct+1;
    end
end

