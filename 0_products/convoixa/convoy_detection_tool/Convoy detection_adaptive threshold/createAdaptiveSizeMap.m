function sizeMap = createAdaptiveSizeMap(statsTable_Weekend_num, statsTable_Week_num)
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

sizeMap = containers.Map('KeyType','char','ValueType','any');
sessionSizeMap = convert(statsTable_Weekend_num);
sizeMap('weekend') = sessionSizeMap;
sessionSizeMap = convert(statsTable_Week_num);
sizeMap('weekday') = sessionSizeMap;

function sessionSizeMap = convert(statsTable_num)
sessionSizeMap = containers.Map('KeyType','char','ValueType','any');
[len,wid] = size(statsTable_num);
for i=1:len
    cam = statsTable_num{i,1};
    ct=1;
    total_num = statsTable_num{i,2};
    if total_num > 10000
        if i==133 || i==134 || i==71 || i==86 || i==87
            sessionSizeMap(cam) = 4;
        else
            for j=3:wid
                if ~isempty(statsTable_num{i,j})
                    num_vehicle = statsTable_num{i,j};
                    tmparray(ct) = num_vehicle;
                    ct=ct+1;
                end
            end
            if ~exist('tmparray', 'var')
                sessionSizeMap(cam) = 0;
            else
                if length(tmparray)==1
                    sessionSizeMap(cam) = 4;
                else
                    if min(tmparray)>10
                        [~, idx] = min(tmparray);
                        sessionSizeMap(cam) = idx+1;
                    elseif min(tmparray)==10
                        [~, idx] = min(tmparray);
                        sessionSizeMap(cam) = idx+1;
                    else
                        m=1;
                        while m<=length(tmparray)
                            tmpnum = tmparray(m);
                            display(tmpnum);
                            if tmpnum<10
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
    else
        sessionSizeMap(cam) = 4;
    end
end