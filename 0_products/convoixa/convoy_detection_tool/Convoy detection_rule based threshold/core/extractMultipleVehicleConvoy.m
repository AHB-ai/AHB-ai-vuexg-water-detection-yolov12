%% N-vehicle Convoy Analysis
%  This script is to extract n-vehicle convoy.

%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>processedConvoyMap</b></td><td>this is processd convoy results.</td></tr>
% <tr><td><b>anprMap</b></td><td>this is a static hash map contains essential information of all ANPR cameras.</td></tr>
% <tr><td><b>threshold_session_num</b></td><td>this is the threshold of convoy session size.</td></tr>
% <tr><td><b>convoy_path</b></td><td>this is the path to store the convoy results.</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>multipleVehicleConvoy</b></td><td>the n-vehicle convoy results are saved in a hashmap.</td></tr>
% </table>
% </html>
%
%% Code
function multipleVehicleConvoy = extractMultipleVehicleConvoy(processedConvoyMap, threshold_session_num, anprMap, convoy_path)
t0 = 734139;
groupConvoyMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(processedConvoyMap);
for i=1:length(keySet)
    val = processedConvoyMap(keySet{i});
    if length(val)>1
        groupConvoyMap(keySet{i}) = val;
    end
end
keySet = keys(groupConvoyMap);
for i=1:length(keySet)
    keyId = keySet{i};
    temp = groupConvoyMap(keyId);
    clusterMap = containers.Map('KeyType','char','ValueType','any');
    for m=1:length(temp)
        val = temp{m};
        group = val{1};
        datetime = group{1,2};
        time_str = datestr(t0+datetime/86400);
        date = str2date(time_str(1:11));
        tf = isKey(clusterMap, date);
        if tf==0
            info{1} = m;
            clusterMap(date) = info;
            clear info;
        end
        if tf==1
            info_tmp = clusterMap(date);
            info_tmp{length(info_tmp)+1} = m;
            clusterMap(date) = info_tmp;
            clear info_tmp;
        end        
    end
    groupConvoyMap(keyId) = {temp, clusterMap};
    clear clusterMap;
end

multipleVehicleConvoy = containers.Map('KeyType','char','ValueType','any');
for i=1:length(keySet)
    keyId = keySet{i};
    val = groupConvoyMap(keyId);
    reads = val{1};
    clusterMap = val{2};
    dateList = keys(clusterMap);  
    resultsMap = containers.Map('KeyType','char','ValueType','any');
    for j=1:length(dateList)
        date = dateList{j};
        index_by_date = clusterMap(date);
        count = 1;
        if length(index_by_date)>1
            id = index_by_date{1};
            group = reads{id}{1};
            timeNumst = group{1,2};
            timeNumed = group{length(group), 2};
            group_anpr = group(:,3);
            for m=2:length(index_by_date)
                index = index_by_date{m};
                group_cmp = reads{index}{1};
                datetime = group_cmp{1,2};
                time_str = datestr(t0+datetime/86400);
                date_cmp = str2date(time_str(1:11));
                timeNumst_cmp = group_cmp{1,2};
                timeNumed_cmp = group_cmp{length(group_cmp), 2};
                group_anpr_cmp = group_cmp(:,3);
                if strcmp(date, date_cmp)
                    if timeNumed>timeNumst_cmp && timeNumst<timeNumed_cmp
                        % compare the similarity of anpr cameras
                        anprDif = setxor(group_anpr, group_anpr_cmp);
                        prctg = length(anprDif)/length(group_anpr);
                        if prctg<0.2
                            if ~isempty(group) && ~isempty(group_cmp)
                                results{count} = reads{index};
                                count = count+1;
                            end
                        end
                    end
                end
            end
        end
        if exist('results', 'var')
            results{length(results)+1} = reads{id};
            resultsMap(date) = results;
            clear results;
        end
    end
    if exist('resultsMap', 'var') && ~isempty(resultsMap)
        multipleVehicleConvoy(keyId) = resultsMap;
        clear resultsMap;
    end
end    
clear groupConvoyMap;
multipleVehicleConvoy = refineMultipleConvoy_v3(multipleVehicleConvoy, threshold_session_num, convoy_path, anprMap);
end

%% Navigation
% * Back to 
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 


%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%