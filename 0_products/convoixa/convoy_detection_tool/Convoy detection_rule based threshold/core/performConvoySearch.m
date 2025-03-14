%% Search for Convoy
%  This function is to search for vehicles travelling in convoy with the target vehicle.

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>carID_cur</b></td><td>the vrm of target vehicle.</td></tr>
% <tr><td><b>camID</b></td><td>the ID of ANPR camera that capture the target vehicle.</td></tr>
% <tr><td><b>dataMap</b></td><td>this is the hash map structure store session data.</td></tr>
% <tr><td><b>threshold_delt</b></td><td>this is the threshold of search window in seconds.</td></tr>
% <tr><td><b>pairMap</b></td><td>this is the data structure to store convoy results.</td></tr>
% <tr><td><b>pos</b></td><td>this is the position of the read contains the target vehicle in the data set (intermediate data format of ANPR read).</td></tr>
% <tr><td><b>idxS</b></td><td>this is a starting position of the subset data contains all reads that have the same camera group as the target vehicle.</td></tr>
% <tr><td><b>idxE</b></td><td>this is a ending position of the subset data contains all reads that have the same camera group as the target vehicle.</td></tr>
% <tr><td><b>t0</b></td><td></td></tr>
% <tr><td><b>search_data</b></td><td>this is data set with the intermediate data format of ANPR read.</td></tr>
% <tr><td><b>time_cur</b></td><td>time stamp of target vehicle.</td></tr>
% <tr><td><b>make, model, color, tax</b></td><td>vehicle's make, model, color, and tax code.</td></tr>
% <tr><td><b>flag_mobile</b></td><td>indicates if the camera is a mobile unit or not.</td></tr>
% <tr><td><b>anprMap</b></td><td></td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>pairMap</b></td><td>this is the hash map structure stores all convoy search results. </td></tr>
% </table>
% </html>
%
%% Code
function [pairMap] = performConvoySearch(carID_cur, camID, dataMap, threshold_delt, pairMap, pos, idxS, idxE, search_data, time_cur, make, model, color, tax, flag_mobile, t0, anprMap)
tmpMap = containers.Map('KeyType','char','ValueType','any');
j = pos-1;
searchUp=0;
count_num_veh = 0;
%%
% Search for previous (search window threshold) seconds for vehicles
% travelling together with the target vehicle
while searchUp == 0
    if j==idxS || j<=0
        searchDown = 0;
        break;
    end;
    carID_nxt = search_data{j,1};
    if ~isKey(tmpMap, carID_nxt)
        clear timeStamp;
        if ~isempty(carID_nxt) 
            if ~strcmp(carID_cur, carID_nxt)
                time = convertTime(search_data, j);
                camID_tmp = search_data{j,4};
                camID_tmp(camID_tmp==' ')='';
                camID_tmp = camNameCorrection(camID_tmp);
                if isKey(dataMap,carID_nxt)
                    if abs(time_cur - time)>threshold_delt
                        searchDown = 0;
                        break;
                    end;
                    if abs(time_cur - time)<threshold_delt || abs(time_cur - time)==threshold_delt
                        if strcmp(camID, camID_tmp)
                            if ~isKey(tmpMap, carID_nxt)
                                num_vehicle = count_num_veh;
                                [pairMap, tmpMap] = storePairs_v2(num_vehicle, carID_cur, carID_nxt, pairMap, j, camID_tmp, search_data, t0, tmpMap, time_cur,camID,make,model,color,tax);                                                                
                                count_num_veh = count_num_veh+1;
                            end
                        else
                            if flag_mobile == 0
                                if isKey(anprMap, camID_tmp)
                                    val = anprMap(camID_tmp);
                                    if isfield(val, 'relatedCams')
                                        relatedCams = val.relatedCams;
                                        for idx=1:length(relatedCams)
                                            camID_cmp = relatedCams{idx};
                                            if strcmp(camID,camID_cmp)
                                                if ~isKey(tmpMap, carID_nxt)
                                                    num_vehicle = count_num_veh;
                                                    [pairMap, tmpMap] = storePairs_v2(num_vehicle, carID_cur, carID_nxt, pairMap, j, camID_tmp, search_data, t0, tmpMap, time_cur,camID,make,model,color,tax);
                                                    count_num_veh = count_num_veh+1;
                                                end
                                            end
                                            clear camID_cmp;
                                        end
                                        clear relatedCams;
                                    end
                                end
                            end
                        end
                    end;
                else
                    if abs(time_cur - time)>threshold_delt
                        searchDown = 0;
                        break;
                    end;
                    if abs(time_cur - time)<threshold_delt || abs(time_cur - time)==threshold_delt
                        if strcmp(camID, camID_tmp)
                            count_num_veh = count_num_veh+1;
                        else
                            if flag_mobile == 0
                                if isKey(anprMap, camID_tmp)
                                    val = anprMap(camID_tmp);
                                    if isfield(val, 'relatedCams')
                                        relatedCams = val.relatedCams;
                                        for idx=1:length(relatedCams)
                                            camID_cmp = relatedCams{idx};
                                            if strcmp(camID,camID_cmp)
                                                count_num_veh = count_num_veh+1;
                                            end
                                            clear camID_cmp;
                                        end
                                        clear relatedCams;
                                    end
                                end
                            end
                        end
                    end;
                end;
            end;
        end;
    end;
    j = j-1;
    clear carID_nxt;
end;
%%
% Search for following (search window threshold) seconds for vehicles
% travelling together with the target vehicle
q = pos+1;
count_num_veh = 0;
while searchDown == 0
    if q>=idxE || q>length(search_data)
        searchDown = 1;
        clear tmpMap;
        break;
    end;
    carID_nxt = search_data{q,1};
    timeStamp = search_data{q,3};
    if ~isKey(tmpMap, carID_nxt)
        clear timeStamp;
        if ~isempty(carID_nxt) 
            if ~strcmp(carID_cur, carID_nxt)
                time = convertTime(search_data, q);
                camID_tmp = search_data{q,4};
                camID_tmp(camID_tmp==' ')='';
                camID_tmp = camNameCorrection(camID_tmp);
                if isKey(dataMap,carID_nxt)
                    if abs(time_cur - time)>threshold_delt
                        searchDown = 1;
                        clear tmpMap;
                        break;
                    end;
                    if abs(time_cur - time)<threshold_delt || abs(time_cur - time)==threshold_delt
                        if strcmp(camID, camID_tmp)
                            if ~isKey(tmpMap, carID_nxt)
                                num_vehicle = count_num_veh;
                                [pairMap, tmpMap] = storePairs_v2(num_vehicle, carID_cur, carID_nxt, pairMap, q, camID_tmp, search_data, t0, tmpMap, time_cur,camID,make,model,color,tax);
                                count_num_veh = count_num_veh+1;
                            end
                        else
                            if flag_mobile == 0
                                if isKey(anprMap, camID_tmp)
                                    val = anprMap(camID_tmp);
                                    if isfield(val, 'relatedCams')
                                        relatedCams = val.relatedCams;
                                        for idx=1:length(relatedCams)
                                            camID_cmp = relatedCams{idx};
                                            if strcmp(camID,camID_cmp)
                                                if ~isKey(tmpMap, carID_nxt)
                                                    num_vehicle = count_num_veh;
                                                    [pairMap, tmpMap] = storePairs_v2(num_vehicle, carID_cur, carID_nxt, pairMap, q, camID_tmp, search_data, t0, tmpMap, time_cur,camID,make,model,color,tax);
                                                    count_num_veh = count_num_veh+1;
                                                end
                                            end
                                            clear camID_cmp;
                                        end
                                        clear relatedCams;
                                    end
                                end
                            end
                        end
                    end;
                else
                    if abs(time_cur - time)>threshold_delt
                        searchDown = 0;
                        break;
                    end;
                    if abs(time_cur - time)<threshold_delt || abs(time_cur - time)==threshold_delt
                        if strcmp(camID, camID_tmp)
                            count_num_veh = count_num_veh+1;
                        else
                            if flag_mobile == 0
                                if isKey(anprMap, camID_tmp)
                                    val = anprMap(camID_tmp);
                                    if isfield(val, 'relatedCams')
                                        relatedCams = val.relatedCams;
                                        for idx=1:length(relatedCams)
                                            camID_cmp = relatedCams{idx};
                                            if strcmp(camID,camID_cmp)
                                                count_num_veh = count_num_veh+1;
                                            end
                                            clear camID_cmp;
                                        end
                                        clear relatedCams;
                                    end
                                end
                            end
                        end
                    end;
                end;
            end;
        end
    end;
    q=q+1;
end;


%% Linked Functions
% * See
% <..\storePairs_v2.m Store Vehicle Information> 

%% Navigation
% * Back to 
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 


%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%
