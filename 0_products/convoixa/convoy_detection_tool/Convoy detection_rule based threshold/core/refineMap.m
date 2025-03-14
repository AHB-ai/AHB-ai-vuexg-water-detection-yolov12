%% Refining Convoy Results
%  This function is to refine convoy results and reformat to a uniform
%  format

%%
%% I/O
% * INPUT:
%    convoyMap: convoy results stored in a hash map structure
%    threshold_pair: this is the threshold of convoy size
%    
% * OUTPUT:
%    convoyMap: refined convoy results saved in a hashmap

%% Code
function convoyMap =  refineMap(convoyMap, threshold_pair)

keySet = keys(convoyMap);
for i = 1:length(keySet)
    globalMap = containers.Map('KeyType','char','ValueType','any');
    reads = convoyMap(keySet{i});
    [len,~] = size(reads);
    count = 1;
    for j = 1:2:len
        camID_cur = reads{j,3};
        camID_nxt = reads{j+1,3};
        time_cur = reads{j,2};
        time_nxt = reads{j+1,2};
        cur_stamp = [camID_cur ' ' num2str(time_cur)];
        nxt_stamp = [camID_nxt ' ' num2str(time_nxt)];
        if ~isKey(globalMap, cur_stamp) && ~isKey(globalMap, nxt_stamp)
            globalMap(cur_stamp) = 1;
            globalMap(nxt_stamp) = 1;
            new_reads(count,:) = reads(j,:);
            count = count+1;
            new_reads(count,:) = reads(j+1,:);
            count = count+1;
        end
    end
    [len,~] = size(new_reads);
    if len>threshold_pair*2
        convoyMap(keySet{i}) = new_reads;
    else
        remove(convoyMap, keySet{i});
    end
    clear new_reads;
end

tmpMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(convoyMap);
for i=1:length(keySet)
    key = keySet{i};
    flag = strfind(key, ' ');
    vrm1 = key(1:flag(1)-1);
    vrm2 = key(flag(1)+1:end);
    reverseKey = [vrm2 ' ' vrm1];
    if ~isKey(tmpMap, key)&& ~isKey(tmpMap, reverseKey)
        tmpMap(key) = convoyMap(key);        
    end
    clear vrm1;
    clear vrm2;
end
clear convoyMap;
convoyMap = tmpMap;

