%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%% 

function combinedResults = search(b,le,combinedResults,timeStampMap_global, time1, time2, lane2, lane1)
flag_d = 0;
flag_u = 0;
idx = b;
while flag_d==0
    display(idx);
    if idx+2<=le
        time = combinedResults{idx+2,2};
        timeStamp1 =  [num2str(time1) ' ' num2str(time)];
        timeStamp2 =  [num2str(time2) ' ' num2str(time)];
        if isKey(timeStampMap_global, timeStamp1) && isKey(timeStampMap_global, timeStamp2)
            num_veh = timeStampMap_global(timeStamp1) - timeStampMap_global(timeStamp2)-1;
            combinedResults{b,9} = num_veh;
            combinedResults{b,11} = time2 - time1;
            combinedResults{b,10} = lane2 - lane1;
            break;
        else
            idx = idx+1;
        end
    end
    if idx+2>le
        break;
    end
end
while flag_u==0
    if idx-1>=1
        time = combinedResults{idx-1,2};
        timeStamp1 =  [num2str(time) ' ' num2str(time1)];
        timeStamp2 =  [num2str(time) ' ' num2str(time2)];
        if isKey(timeStampMap_global, timeStamp1) && isKey(timeStampMap_global, timeStamp2)
            num_veh = timeStampMap_global(timeStamp1) - timeStampMap_global(timeStamp2)-1;
            combinedResults{b,9} = num_veh;
            combinedResults{b,11} = time2 - time1;
            combinedResults{b,10} = lane2 - lane1;
            break;
        else
            idx = idx-1;
        end
    end
    if idx-1<1
        break;
    end
end