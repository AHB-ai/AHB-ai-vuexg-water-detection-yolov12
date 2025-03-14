
function [matrix] = generateFeatures_v2(map)
ct=1;
keySet = keys(map);
matrix = zeros(length(keySet),11);
for i=1:length(map)
    val = map(keySet{i});
    for j=1:length(val)
        stats = val{j}{2};
        delta_t_array = stats(:,2);
        % column 1 is standard deviation of absolute value of time difference
        matrix(ct,1) = std(abs(stats(:,2)));
        % column 2 is the mean value of absolute time difference
        matrix(ct,2) = mean(abs(stats(:,2)));
        % column 3 is standard deviation of number of vehicles in between
        matrix(ct,3) = std(stats(:,3));
        % column 4 is the mean value of number of vehicles in between
        matrix(ct,4) = mean(stats(:,3));
        % column 5 is number of change order/length of convoy session
        matrix(ct,5) = stats(2,4)/length(delta_t_array);
        % column 6 is the duration of the convoy session
        matrix(ct,6) = stats(4,4);
        % column 7 is the number of different cameras within the convoy session
        matrix(ct,7) = stats(5,4);
        % column 8 is the number of times this vehicle has been captured
        % within this convoy session
        [len,~] = size(stats);
        matrix(ct,8) = len;
        % column 9 is number of different cameras/number of times has been
        % captured
        matrix(ct,9) = stats(5,4)/len;
        % column 10 and 11 record the index       
        matrix(ct,10) = i;
        matrix(ct,11) = j;
        ct=ct+1;
    end
end

