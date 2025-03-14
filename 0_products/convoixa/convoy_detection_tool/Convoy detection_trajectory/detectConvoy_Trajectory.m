function convoyArray = detectConvoy_Trajectory(rankTable, tmpMap, anprMap, camMap, session_break)
[lenRankTable,~]=size(rankTable);
tmpArray = cell(lenRankTable,1);
keySet = keys(tmpMap);
count = 1;
for i=1:lenRankTable
    display(i);
    st_time_seed = rankTable(i,3);
    ed_time_seed = rankTable(i,4);
    %if st_time_seed ~= ed_time_seed && (ed_time_seed-st_time_seed)>3600
    if(ed_time_seed-st_time_seed)>0
        for j=i+1:lenRankTable
            st_time = rankTable(j,3);
            ed_time = rankTable(j,4);            
            flag_convoy = 0;
            if ed_time_seed>st_time && st_time_seed<=ed_time
                idx_seed = rankTable(i,2);
                len_seed = rankTable(i,1);
                val_seed = tmpMap(keySet{idx_seed});
                idx = rankTable(j,2);
                len = rankTable(j,1);
                val = tmpMap(keySet{idx});
                [flag_convoy, mat_score_time] = compareTrajectory(val_seed, len_seed, val, len, anprMap, camMap, session_break);
            elseif ed_time>st_time_seed && st_time<=ed_time_seed
                idx_seed = rankTable(i,2);
                len_seed = rankTable(i,1);
                val_seed = tmpMap(keySet{idx_seed});
                idx = rankTable(j,2);
                len = rankTable(j,1);
                val = tmpMap(keySet{idx});
                [flag_convoy, mat_score_time] = compareTrajectory(val_seed, len_seed, val, len, anprMap, camMap, session_break);
            end
            if flag_convoy == 1
                tmpArray{count} = {idx_seed, idx, mat_score_time};
                count = count+1;
            end
        end
    end
end

convoyArray = cell(count,1);
for m=1:count-1
    convoyArray{m} = tmpArray{m};
end
clear tmpArray;
end