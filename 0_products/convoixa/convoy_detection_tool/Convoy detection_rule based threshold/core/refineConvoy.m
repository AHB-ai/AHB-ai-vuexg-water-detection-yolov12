%% Refining Convoy Results
%  This function is to refine convoy results and reformat to a uniform format.

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>pairMap</b></td><td>convoy results stored in a hash map structure.</td></tr>
% <tr><td><b>threshold_pair</b></td><td>this is the threshold of convoy session size.</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>convoyMap</b></td><td>refined convoy results saved in a hashmap. </td></tr>
% </table>
% </html>
%
%% Code
function convoyMap =  refineConvoy(pairMap, threshold_pair, anprMap)
%% 
% Filtering convoy results and organise it into a human-readable format.
keySet = keys(pairMap);
convoyMap = containers.Map('KeyType','char','ValueType','any');
for id=1:length(keySet)
    key_tmp = keySet{id};
    val = pairMap(key_tmp);
    if length(val)>threshold_pair
        tmp = strfind(key_tmp, ' ');
        carID_cur = key_tmp(1:tmp-1);
        carID_nxt = key_tmp(tmp+1:end);
        test_pair = cell(length(val),3);
        for mi=1:length(val)
            time_cur = val{mi}{1};
            test_pair{mi,1} = time_cur;
            test_pair{mi,2} = mi;
        end
        test_pair = sortrows(test_pair,1);
        count =1;
        pair_write = cell(length(val),7);
        [tmp_len,~]=size(test_pair);
        for im = 1:tmp_len
            idx = test_pair{im,2};
            time_cur = val{idx}{1};
            camID_cur = val{idx}{2};
            make_cur = val{idx}{3};
            model_cur = val{idx}{4};
            color_cur = val{idx}{5};
            tax_cur = val{idx}{6};
            time_nxt = val{idx}{7};
            camID_nxt = val{idx}{8};
            make_nxt = val{idx}{9};
            model_nxt = val{idx}{10};
            color_nxt = val{idx}{11};
            tax_nxt = val{idx}{12};
            number_car_between = val{idx}{13};
            pair_write{count,1} = carID_cur;
            pair_write{count,2} = time_cur;
            pair_write{count,3} = camID_cur;
            pair_write{count,4} = make_cur;
            pair_write{count,5} = model_cur;
            pair_write{count,6} = color_cur;
            pair_write{count,7} = tax_cur;
            pair_write{count,8} = number_car_between;
            count = count+1;
            pair_write{count,1} = carID_nxt;
            pair_write{count,2} = time_nxt;
            pair_write{count,3} = camID_nxt;
            pair_write{count,4} = make_nxt;
            pair_write{count,5} = model_nxt;
            pair_write{count,6} = color_nxt;
            pair_write{count,7} = tax_nxt;
            count = count+1;
        end
        convoyMap(key_tmp) = pair_write;
        clear pair_write;
    end
end

clear keySet;
clear key_tmp;
clear id;
clear j;
%%
% Further filtering convoy results to eliminate repeated and mis-match
% convoy results.
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
%%
% Organise convoy results to include some statistic information in terms of
% lane difference, time difference between each two vehicles, and number of
% intervening vehicle between two vehicles, status of changing order, and
% duration of each convoy session.
keySet = keys(convoyMap);
for i=1:length(keySet)
    key = keySet{i};
    temp = convoyMap(key);
    convoys = temp(:,1:7);
    number_vehicles_between = temp(:,8);
    [height,width]=size(convoys);    
    convoy_stats = zeros(height/2,5);
    % initilise some variables
    ct_change_order = 0;
    ct_time_difference = 0;
    ct_change_lane = 0;
    time_st = convoys{1,2};
    time_ed = convoys{height-1,2};
    time_span = time_ed - time_st;
    time_st_2 = convoys{2,2};
    time_difference = time_st_2 - time_st;    
    if time_difference>0
        flag_delta_t = 0;
    else
        flag_delta_t = 1;
    end
    camIdMap = containers.Map('KeyType','char','ValueType','any');
    % retrieve lane information 
    for m=1:height
        camId = convoys{m,3};
        laneNum = getLaneNumber(anprMap, camId);
        convoys{m,width+1} = laneNum;
    end 
    % generate raw feature of the convoy
    ct=1;
    for m=1:2:height-1
        laneNum1 = convoys{m,width+1};
        laneNum2 = convoys{m+1,width+1};
        % record lane difference
        laneDiff = laneNum1-laneNum2;        
        convoy_stats(ct,1) = laneDiff; 
        camId_1 = convoys{m,3};
        if ~isKey(camIdMap, camId_1)
            camIdMap(camId_1) = 1;
        else
            num = camIdMap(camId_1);
            camIdMap(camId_1) = num+1;
        end
        time_1 = convoys{m,2};
        time_2 = convoys{m+1,2};
        camId_2 = convoys{m+1,3};        
        deltaT = time_2 - time_1;    
        % record time difference between two vehicles
        convoy_stats(ct,2) = deltaT; 
        if abs(deltaT)<=20
            ct_time_difference = ct_time_difference+1; 
        % record number of times two vehicles changes order
        end
        if flag_delta_t==0
            if deltaT<0
                ct_change_order = ct_change_order+1;
                flag_delta_t = 1;
            end
        else
            if deltaT>0
                ct_change_order = ct_change_order+1;
                flag_delta_t = 0;
            end
        end
        % record number of times two vehicles change lane.
        if ~strcmp(camId_1, camId_2)
            ct_change_lane = ct_change_lane+1;
        end       
        convoy_stats(ct,3) = number_vehicles_between{m,1}; 
        ct=ct+1;
    end
    
    for n=1:2:height-1
        realtime1 = convoys{n,2};
        realtime2 = convoys{n+1,2};
        if realtime1>realtime2
            tmp1 = convoys(n,:);
            tmp2 = convoys(n+1,:);
            convoys(n,:) = tmp2;
            convoys(n+1,:) = tmp1;
            clear tmp1;
            clear tmp2;
        end
    end    
    convoy_stats(1,4) = ct_time_difference;
    convoy_stats(2,4) = ct_change_order;
    convoy_stats(3,4) = ct_change_lane;
    convoy_stats(4,4) = time_span;
    convoy_stats(5,4) = length(camIdMap); 
    
    for n=1:(height/2)
        tmp = n*2;
        convoys{tmp-1,width+2} = convoy_stats(n,3);
        convoys{tmp-1,width+3} = convoy_stats(n,1);
        convoys{tmp-1,width+4} = abs(convoy_stats(n,2));
    end
    convoyMap(key) = {convoys,convoy_stats};
end


%% Navigation
% * Back to 
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 

%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%
