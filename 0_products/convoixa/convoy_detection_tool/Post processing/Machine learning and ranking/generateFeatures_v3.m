
function [matrix_1, matrix_2] = generateFeatures_v3(map)
ct_1=1;
ct_2=1;
keySet = keys(map);
%matrix_1 = zeros(length(keySet),11);
for i=1:length(map)
    val = map(keySet{i});
    if length(val)==1
        for j=1:length(val)
            stats = val{j}{2};
            delta_t_array = stats(:,2);
            % column 1 is standard deviation of absolute value of time difference
            matrix_1(ct_1,1) = std(abs(stats(:,2)));
            % column 2 is the mean value of absolute time difference
            matrix_1(ct_1,2) = mean(abs(stats(:,2)));
            % column 3 is standard deviation of number of vehicles in between
            matrix_1(ct_1,3) = std(stats(:,3));
            % column 4 is the mean value of number of vehicles in between
            matrix_1(ct_1,4) = mean(stats(:,3));
            % column 5 is number of change order/length of convoy session
            matrix_1(ct_1,5) = stats(2,4)/length(delta_t_array);
            % column 6 is the duration of the convoy session
            matrix_1(ct_1,6) = stats(4,4);
            % column 7 is the number of different cameras within the convoy session
            matrix_1(ct_1,7) = stats(5,4);
            % column 8 is the number of times this vehicle has been captured
            % within this convoy session
            [len,~] = size(stats);
            matrix_1(ct_1,8) = len;
            % column 9 is number of different cameras/number of times has been
            % captured
            matrix_1(ct_1,9) = stats(5,4)/len;
            % column 10 and 11 record the index
            matrix_1(ct_1,10) = i;
            matrix_1(ct_1,11) = j;
            ct_1=ct_1+1;
        end
    else
        for j=1:length(val)
            stats = val{j}{2};
            delta_t_array = stats(:,2);
            % column 1 is standard deviation of absolute value of time difference
            matrix_2(ct_2,1) = std(abs(stats(:,2)));
            % column 2 is the mean value of absolute time difference
            matrix_2(ct_2,2) = mean(abs(stats(:,2)));
            % column 3 is standard deviation of number of vehicles in between
            matrix_2(ct_2,3) = std(stats(:,3));
            % column 4 is the mean value of number of vehicles in between
            matrix_2(ct_2,4) = mean(stats(:,3));
            % column 5 is number of change order/length of convoy session
            matrix_2(ct_2,5) = stats(2,4)/length(delta_t_array);
            % column 6 is the duration of the convoy session
            matrix_2(ct_2,6) = stats(4,4);
            % column 7 is the number of different cameras within the convoy session
            matrix_2(ct_2,7) = stats(5,4);
            % column 8 is the number of times this vehicle has been captured
            % within this convoy session
            [len,~] = size(stats);
            matrix_2(ct_2,8) = len;
            % column 9 is number of different cameras/number of times has been
            % captured
            matrix_2(ct_2,9) = stats(5,4)/len;
            % column 10 and 11 record the index
            matrix_2(ct_2,10) = i;
            matrix_2(ct_2,11) = j;
            ct_2=ct_2+1;
        end
    end
end

