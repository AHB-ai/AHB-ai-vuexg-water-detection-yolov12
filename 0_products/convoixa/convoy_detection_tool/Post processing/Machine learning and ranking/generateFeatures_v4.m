
function [rankMat] = generateFeatures_v4(crimeMap, anprMap, searchRadius, convoyMap, repeatedConvoyMap, multipleVehicleMap)
ct=1;
keySet = keys(convoyMap);
rankMat = zeros(length(keySet),11);
for i=1:length(convoyMap)
    display(i);
    key = keySet{i};
    val = convoyMap(key);
    flag = strfind(key, ' ');
    vrm1 = key(1:flag(1)-1);
    vrm2 = key(flag(1)+1:end);
    for j=1:length(val)        
        reads = val{j}{1};
        [len,~]=size(reads);
        speed_array = [];
        ct=1;
        startTimeTemp = reads{1,2};
        endTimeTemp = reads{len,2};
        startTimeStr = convertTime(startTimeTemp);
        endTimeStr = convertTime(endTimeTemp);
        flag = strfind(startTimeStr,' ');
        startHourStr = startTimeStr(flag(1)+1:end);
        dateStr = startTimeStr(1:flag(1)-1);
        temp = str2date(dateStr);
        flag = strfind(temp, '-');
        date = [temp(flag(2)+1:end) '-' temp(flag(1)+1:flag(2)-1)];
        clear flag;
        flag = strfind(startTimeStr,' ');
        endHourStr = endTimeStr(flag(1)+1:end);
        clear flag;
        startTimeNum = convertHour(startHourStr, ':');
        endTimeNum = convertHour(endHourStr, ':');               
        
        
        stats = val{j}{2};
        delta_t_array = stats(:,2);
        % column 1 is standard deviation of absolute value of time difference
        rankMat(ct,1) = std(abs(stats(:,2)));
        % column 2 is the mean value of absolute time difference
        rankMat(ct,2) = mean(abs(stats(:,2)));
        % column 3 is standard deviation of number of vehicles in between
        rankMat(ct,3) = std(stats(:,3));
        % column 4 is the mean value of number of vehicles in between
        rankMat(ct,4) = mean(stats(:,3));
        % column 5 is number of change order/length of convoy session
        rankMat(ct,5) = stats(2,4)/length(delta_t_array);
        % column 6 is the duration of the convoy session
        rankMat(ct,6) = stats(4,4);
        % column 7 is the number of different cameras within the convoy session
        rankMat(ct,7) = stats(5,4);
        % column 8 is the number of times this vehicle has been captured
        % within this convoy session
        [len,~] = size(stats);
        rankMat(ct,8) = len;
        % column 9 is number of different cameras/number of times has been
        % captured
        rankMat(ct,9) = stats(5,4)/len;
        % column 10 and 11 record the index     
        rankMat(ct,10) = i;
        rankMat(ct,11) = j;
        % Repeated Convoy
        if isKey(repeatedConvoyMap,key)
            temp1 = repeatedConvoyMap(key);
            leng = temp1.length;
            rankMat(ct,12) = leng;
        else
            rankMat(ct,12) = 0;
        end
        % Multiple vehicle Convoy
        if isKey(multipleVehicleMap, vrm1) && isKey(multipleVehicleMap, vrm2)
            rankMat(ct,13) = 2;
        else
            rankMat(ct,13) = 0;
        end
        if isKey(multipleVehicleMap, vrm1) || isKey(multipleVehicleMap, vrm2)
            rankMat(ct,14) = 1;
        else
            rankMat(ct,14) = 0;
        end
        
        % record start time
        rankMat(ct,15) = startTimeNum;
        
        % record end time
        rankMat(ct,16) = endTimeNum;
        
        % Crime Rate with search radius of 1 mile
        count = retrieveCrimeStats(date, reads, crimeMap, anprMap, searchRadius);
        rankMat(ct,17) = count;
        ct=ct+1;
    end
end

