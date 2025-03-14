
[len,wid] = size(statsTable_Weekend);
statsTable_Weekend_num = cell(len,wid);

for i=1:len
    cam = statsTable_Weekend{i,1};
    num = statsTable_Weekend{i,2};
    statsTable_Weekend_num{i,1} = cam;
    statsTable_Weekend_num{i,2} = num;
    for j=3:wid
        if ~isempty(statsTable_Weekend{i,j})
            prob = statsTable_Weekend{i,j};
            num_vehicle = num*prob;
            statsTable_Weekend_num{i,j} = num_vehicle;
        end
    end
end

%[len,wid] = size(statsTable_Weekend_num);

sizeMap = containers.Map('KeyType','char','ValueType','any');
[len,wid] = size(statsTable_Week_num);
sessionSizeMap = containers.Map('KeyType','char','ValueType','any');
for i=1:len
    cam = statsTable_Week_num{i,1};
    j=3;
    ct=1;
    for j=3:wid
        if ~isempty(statsTable_Week_num{i,j})
            num_vehicle = statsTable_Week_num{i,j};
            tmparray(ct) = num_vehicle;
            ct=ct+1;
        end
    end
    if ~exist('tmparray', 'var')
        sessionSizeMap(cam) = 0;
    else
        if length(tmparray)==1
            sessionSizeMap(cam) = 2;
        else
            if min(tmparray)>6
                [value, idx] = min(tmparray);
                sessionSizeMap(cam) = idx+1;
            elseif min(tmparray)==6
                [value, idx] = min(tmparray);
                sessionSizeMap(cam) = idx+1;
            else
                m=1;
                while m<=length(tmparray)
                    tmpnum = tmparray(m);
                    display(tmpnum);
                    if tmpnum<6
                        sessionSizeMap(cam) = m+1;
                        break;
                    end
                    m=m+1;
                end
            end
        end
        clear tmparray;
        clear ct;
    end
end



target = 1000000;
[len,wid] = size(statsTable_Week_num);
for i=1:len
    total_num = statsTable_Week_num{i,2}; 
    rem = target/total_num;
    for j=3:wid
         if ~isempty(statsTable_Week_num{i,j})
             num_vehicle = statsTable_Week_num{i,j};
             statsTable_Week_num{i,j} = num_vehicle*rem;
         end
    end
end

target = 1000000;
[len,wid] = size(statsTable_Weekend_num);
for i=1:len
    total_num = statsTable_Weekend_num{i,2}; 
    rem = target/total_num;
    for j=3:wid
         if ~isempty(statsTable_Weekend_num{i,j})
             num_vehicle = statsTable_Weekend_num{i,j};
             statsTable_Weekend_num{i,j} = num_vehicle*rem;
         end
    end
end