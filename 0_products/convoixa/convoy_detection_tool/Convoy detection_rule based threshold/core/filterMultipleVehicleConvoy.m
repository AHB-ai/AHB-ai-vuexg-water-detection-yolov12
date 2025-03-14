%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%% 
function [output] = filterMultipleVehicleConvoy(input, time_spam)
output = containers.Map('KeyType','char','ValueType','any');
keySet = keys(input);
for i=1:length(keySet)
    key = keySet{i};
    tmpval = input(key);
    for j=1:length(tmpval)
        val=tmpval{j};
        session_data = val{2};
        [~, start_time] = getStartTime(session_data);
        [~, end_time] = getEndTime(session_data);
        if (end_time-start_time)>time_spam
            if ~isKey(output, key)
                results{1} = session_data;
                output(key) = results;
                clear results;
            else
                results = output(key);
                results{length(results)+1} = session_data;
                output(key) = results;
                clear results;
            end
        end
    end
end
end

