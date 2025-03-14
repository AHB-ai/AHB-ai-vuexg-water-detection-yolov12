function [flag_convoy, mat_score_time] = compareTrajectory_backup(val_seed, len_seed, val, len, anprMap, camMap, session_break)

flag_convoy = 0;
mat_score_time = [];
anpr_seed = val_seed(:,2);
anpr = val(:,2);

ct = 1;
for i=1:len_seed
    cam_seed = anpr_seed{i};
    for j=ct:len
        cam = anpr{j};
        camtmp = [cam_seed ' ' cam];
        if isKey(camMap, camtmp)
            ct = ct+1;
            break;
        end
    end
end

if ct/len_seed>0.5
    mat_dist = zeros(len_seed, len);
    mat_time = zeros(len_seed, len);
    for m=1:len_seed
        time_seed = val_seed{m,1};
        cam_seed = val_seed{m,2};
        for j=1:len
            time = val{j,1};
            mat_time(m,j) = abs(time_seed - time);
            cam = val{j,2};
            camtmp = [cam_seed ' ' cam];
            if isKey(camMap, camtmp)
                distance = 0;
            else
                distance = calculateDistance(cam_seed, cam, anprMap);
            end
            mat_dist(m,j) = distance;
        end
    end
    
    mat_score_time = zeros(len_seed, 2);
    ct=0;
    for m=1:len_seed
        if ct+1<=len
            [min_time, idx_time] = min(mat_time(m,ct+1:end));
            mat_score_time(m,1) = min_time;
            mat_score_time(m,2) = idx_time+ct;
            ct = idx_time+ct;
        end
    end
    
    count_dist = 0;
    %mean_time = 0;
    for m=1:len_seed
        idx = mat_score_time(m,2);
        if idx>0
            min_distance = nanmin(mat_dist(m,:));
            idx_distance = mat_dist(m,idx);
            if min_distance==idx_distance
                %display(m);
                %mean_time = mean_time + mat_score_time(m,1);
                %if mat_score_time(m,1)<600
                    count_dist = count_dist+1;
                %end
                %display(mean_time);
                %display(count_dist);
            end
        end
    end
    if count_dist/len_seed>0.5 && count_dist>=session_break
        %if count_dist>=session_break && count_dist/len_seed>0.5 && mean_time/count_dist<600
        flag_convoy = 1;
    end
    %end
end



