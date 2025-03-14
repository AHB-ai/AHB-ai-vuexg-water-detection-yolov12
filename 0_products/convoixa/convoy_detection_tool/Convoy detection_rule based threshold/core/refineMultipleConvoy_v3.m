%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
function multipleVehicleConvoy = refineMultipleConvoy_v3(multipleVehicleConvoy, threshold_session_num, convoy_path, anprMap)
t0 = 734139;
keySet = keys(multipleVehicleConvoy);
% convoy
for i=1:length(keySet)
    display(i);
    key = keySet{i};
    map = multipleVehicleConvoy(key);
    subkey = keys(map);
    timeStampMap_global = containers.Map('KeyType','char','ValueType','any');
% merge multiple 2-vehicles convoy into a large table of multiple vehile
    for j=1:length(subkey)
        val = map(subkey{j});
        for m=1:length(val)
            read = val{m}{1};
            [height,~] = size(read);
            for n=1:2:height-1
                time1 = read{n,2};
                time2 = read{n+1,2};
                num_veh = read{n,9};
                if time1<time2
                    timeStamp = [num2str(time1) ' ' num2str(time2)];
                else
                    timeStamp = [num2str(time2) ' ' num2str(time1)];
                end
                if ~isKey(timeStampMap_global, timeStamp)
                    timeStampMap_global(timeStamp) = num_veh;
                    clear timeStamp;
                end
            end
        end
    end
    
    for j=1:length(subkey)
        date = subkey{j};
        convoyFile = [convoy_path '\' date '_export.mat'];
        load(convoyFile);
        numVehicleMap = containers.Map('KeyType','char','ValueType','any');
        keySet_convoy = keys(convoyMap);
        for ii = 1:length(keySet_convoy)
            timeStampMap = containers.Map('KeyType','char','ValueType','any');
            val = convoyMap(keySet_convoy{ii});
            read = val{1};
            [height,~] = size(read);
            for n=1:2:height-1
                time1 = read{n,2};
                time2 = read{n+1,2};
                num_veh = read{n,9};
                if time1<time2
                    timeStamp = [num2str(time1) ' ' num2str(time2)];
                else
                    timeStamp = [num2str(time2) ' ' num2str(time1)];
                end
                if ~isKey(timeStampMap, timeStamp)
                    timeStampMap(timeStamp) = num_veh;
                    clear timeStamp;
                end
            end
            numVehicleMap(keySet_convoy{ii}) = timeStampMap;
            clear timeStampMap;
        end
        
        val = map(subkey{j});
        temp = {};
        vrmMap = containers.Map('KeyType','char','ValueType','any');
        for m=1:length(val)
            results = val{m}{1};
            for n=1:length(results)
                vrm = results{n,1};
                if ~isKey(vrmMap,vrm)
                    vrmMap(vrm) = '';
                end
            end
            temp = [temp; results];
        end
        num_vrm = length(vrmMap);
        clear vrmMap;
        tempResults = sortrows(temp, 2);
        combinedResults = {};
        count=1;
        [le_temp,~]=size(tempResults);
        for idx=1:le_temp-1
            vrm1 = tempResults{idx,1};
            time1 = tempResults{idx,2};
            vrm2 = tempResults{idx+1,1};
            time2 = tempResults{idx+1,2};
            if ~strcmp(vrm1, vrm2) && time1~=time2
                combinedResults(count,:) = tempResults(idx,:);
                count=count+1;
            end
        end
        combinedResults(count,:) = tempResults(length(tempResults),:);
        [le,~] = size(combinedResults);
        emptyColumn = cell(le,1);
        combinedResults(:,9)=emptyColumn;
        combinedResults(:,10)=emptyColumn;
        combinedResults(:,11)=emptyColumn;
        % calculate the number of intervening vehicles for multiple vehilce
        % convoy session
        
        for b=1:le-1
            vrm1 = combinedResults{b,1};
            vrm2 = combinedResults{b+1,1};
            time1 = combinedResults{b,2};
            time2 = combinedResults{b+1,2};
            cam1 = combinedResults{b,3};
            cam2 = combinedResults{b+1,3};
            lane1 = combinedResults{b,8};
            lane2 = combinedResults{b+1,8};
            vrmKey1 = [vrm1 ' ' vrm2];
            vrmKey2 = [vrm2 ' ' vrm1];
            timeKey = [num2str(time1) ' ' num2str(time2)];
            
            flag_cam = 0;
            if strcmp(cam1,cam2)
                flag_cam = 1;
            else
                if isKey(anprMap, cam1)
                    anprVal = anprMap(cam1);
                    if isfield(anprVal, 'relatedCams')
                        relatedCams = anprVal.relatedCams;
                        for num = 1:length(relatedCams)
                            camtmp = relatedCams{num};
                            if strcmp(camtmp, cam2)
                                flag_cam = 1;
                            end
                        end
                    else
                        if strcmp(cam1, cam2)
                            flag_cam = 1;
                        end
                    end
                end
            end
            if ~isempty(time1) && ~isempty(time2) && flag_cam==1
                if isKey(numVehicleMap, vrmKey1)
                    subMap = numVehicleMap(vrmKey1);
                    if isKey(subMap,timeKey)
                        num_veh = subMap(timeKey);
                        combinedResults{b,9} = num_veh;
                        combinedResults{b,11} = time2 - time1;
                        combinedResults{b,10} = lane2 - lane1;
                    else
                        combinedResults = search(b,le,combinedResults,timeStampMap_global, time1, time2, lane2, lane1);
                    end
                else
                    if isKey(numVehicleMap, vrmKey2)
                        subMap = numVehicleMap(vrmKey2);
                        if isKey(subMap,timeKey)
                            num_veh = subMap(timeKey);
                            combinedResults{b,9} = num_veh;
                            combinedResults{b,11} = time2 - time1;
                            combinedResults{b,10} = lane2 - lane1;
                        else
                            combinedResults = search(b,le,combinedResults,timeStampMap_global, time1, time2, lane2, lane1);
                        end
                    else
                        combinedResults = search(b,le,combinedResults,timeStampMap_global, time1, time2, lane2, lane1);
                    end
                end
            end
        end
        
        for a=1:le
            time = combinedResults{a,2};
            real_time = datestr(t0+time/86400);
            combinedResults{a,2} = real_time;
        end
        data{j} = {num_vrm, combinedResults};
        clear combinedResults;
    end
    multipleVehicleConvoy(key) = data;
    clear data;
end

%%%% Need to insert some code to delete repeated multiple vehicle session
keySet = keys(multipleVehicleConvoy);
for m=1:length(keySet)
    key = keySet{m};
    tmp_val = multipleVehicleConvoy(key);
    for ii=1:length(tmp_val)
        num_vehicle = tmp_val{ii}{1};
        content = tmp_val{ii}{2};
        % exclude the convoy session that the number of vehicles invovled
        % less than 3
        if num_vehicle<3
            tmp_val{ii} = {};
        else
            [len,~] = size(content);
            num_session = len/num_vehicle;
            % exclude the convoy session that the number of session less
            % than the threshold.
            if num_session<threshold_session_num
                tmp_val{ii} = {};
            end
        end
    end
    for ii=1:length(tmp_val)
        ct=1;
        if ~isempty(tmp_val{ii})
            new_val{ct} = tmp_val{ii};
            ct = ct+1;
        end
    end
    if exist('new_val', 'var')
        multipleVehicleConvoy(key) = new_val;
        clear new_val;
    else
        remove(multipleVehicleConvoy, key);
    end
end

