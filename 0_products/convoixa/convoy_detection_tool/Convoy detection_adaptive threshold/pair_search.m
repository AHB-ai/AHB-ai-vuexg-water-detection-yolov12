% This script is an updated version of pair_search_2. This version has
% added several addition search criterias.
% INPUT:
% -single_sessionMap: this stores single session for all vehicles
% -search_data: is the ANPR reads
% -threshold_delt: is the search window threshold (in minutes)
% -camMap: is the map where stores information about how the ANPR reads is
% stored, so can provide a quicker way for searching pairs.
% OUTPUT:
% -pairMap: this stores all pairs found
% Haiyue@Jun 2015

function [pairMap] = pair_search(journeyMap, search_data, threshold_delt, camMap, anprMap)
t0 = 734139;
pairMap = containers.Map('KeyType','char','ValueType','any');
N = length(journeyMap);
keySet = keys(journeyMap);
globalMap = containers.Map('KeyType','char','ValueType','any');

for i = 1:N
    %display(i);
    [pairMap, globalMap] = searchConvoy(t0, journeyMap, pairMap, globalMap, keySet, i, search_data, threshold_delt, camMap, anprMap);
end
clear globalMap;

function [time_nxt] = getANPRreads(search_data, idx, t0)
dateTmp = datenum(search_data{idx,2}, 'dd-mm-yyyy')-t0;
dateNum = dateTmp*24*3600;
sectmp = str2num(strrep(search_data{idx,3},':', ' '));
timeNum = sectmp(1)*3600+sectmp(2)*60+sectmp(3);
time_nxt = dateNum+timeNum;

function globalMap = storeTime(globalMap, carId_cur, search_data, idx)
timeStamp = search_data{idx,3};
if ~isKey(globalMap, carId_cur)
    miniMap = containers.Map('KeyType','char','ValueType','any');
    miniMap(timeStamp)=1;
    globalMap(carId_cur) = miniMap;
    clear miniMap;
else
    miniMap = globalMap(carId_cur);
    miniMap(timeStamp)=1;
    globalMap(carId_cur) = miniMap;
    clear miniMap;
end

function [pairMap, globalMap, tmpMap] = storePairs(carID_cur, carID_nxt, pairMap, globalMap, idx, camID_tmp, search_data, t0, tmpMap, time_cur,camID)
keyStr_original = [carID_cur ' ' carID_nxt];
keyStr_reverse = [carID_nxt ' ' carID_cur];
tf_o = isKey(pairMap, keyStr_original);
tf_r = isKey(pairMap, keyStr_reverse);
[time_nxt] = getANPRreads(search_data, idx, t0);
if tf_o == 1
    pair_data = pairMap(keyStr_original);
    pair_data{length(pair_data)+1}={time_cur,camID,time_nxt,camID_tmp};
    pairMap(keyStr_original) = pair_data;
    tmpMap(carID_nxt)=1;
    globalMap = storeTime(globalMap, carID_cur, search_data, idx);
    clear pair_data;
    clear time_nxt make_nxt model_nxt color_nxt tax_nxt;
end;
if tf_o == 0 && tf_r == 0
    pair_data{1}={time_cur,camID,time_nxt,camID_tmp};
    pairMap(keyStr_original) = pair_data;
    tmpMap(carID_nxt)=1;
    globalMap = storeTime(globalMap, carID_cur, search_data, idx);
    clear pair_data;
    clear time_nxt make_nxt model_nxt color_nxt tax_nxt;
end

function [pairMap, globalMap] = searchConvoy(t0, journeyMap, pairMap, globalMap, keySet, i, search_data, threshold_delt, camMap, anprMap)

carID_cur = keySet{i};
if ~isempty(carID_cur)
    journey = journeyMap(carID_cur);
    for m = 1:length(journey)
        time_cur = journey{m}.time;
        pos = journey{m}.pos;
        camID = search_data{pos,4};
        camID(camID==' ')='';
        camID = camNameCorrection(camID);
        tmp = strfind(camID, '.');
        flag_mobile = 0;
        if isempty(tmp)
            camKey = 'Mobile Unit';
            flag_mobile = 1;
        end
        if ~isempty(tmp)
            if strcmp(camID(1:4), 'ANPR')
                if tmp(1)==6
                    camKey = ['ANPR0' camID(tmp(1)-1)];
                end
                if tmp(1)>6
                    camKey = camID(1:(tmp(1)-1));
                end
                flag_mobile = 0;
            end
        end
        val = camMap(camKey);
        idxS = val{1};
        idxE = val{2};
        pos = journey{m}.pos;
        
        tmpMap = containers.Map('KeyType','char','ValueType','any');
        j = pos-1;
        searchUp=0;
        while searchUp == 0
            if j==idxS || j<=0
                searchDown = 0;
                break;
            end;
            carID_nxt = search_data{j,1};
            timeStamp = search_data{j,3};
            flag_search=0;
            if ~isKey(tmpMap, carID_nxt)
                if ~isKey(globalMap, carID_cur)
                    flag_search=1;
                else
                    miniMap = globalMap(carID_cur);
                    if ~isKey(miniMap,timeStamp)
                        flag_search=1;
                    else
                        flag_search=0;
                    end
                end
                clear timeStamp;
                clear miniMap;
                if ~isempty(carID_nxt) && flag_search==1
                    if ~strcmp(carID_cur, carID_nxt)
                        if isKey(journeyMap,carID_nxt)
                            time = convertTime(search_data, j);
                            camID_tmp = search_data{j,4};
                            camID_tmp(camID_tmp==' ')='';
                            camID_tmp = camNameCorrection(camID_tmp);
                            if abs(time_cur - time)>threshold_delt
                                searchDown = 0;
                                break;
                            end;
                            if abs(time_cur - time)<threshold_delt || abs(time_cur - time)==threshold_delt
                                if flag_mobile == 0
                                    if isKey(anprMap, camID)
                                        val = anprMap(camID);
                                        if isfield(val, 'relatedCams')
                                            relatedCams = val.relatedCams;
                                            relatedCams{length(relatedCams)+1} = camID;
                                        end
                                        if ~isfield(val, 'relatedCams')
                                            relatedCams{1} = camID;
                                        end
                                    end
                                    if ~isKey(anprMap, camID)
                                        relatedCams{1} = camID;
                                    end
                                end
                                if flag_mobile ==1
                                    relatedCams{1} = camID;
                                end
                                for idx = 1:length(relatedCams)
                                    camID_cmp = relatedCams{idx};
                                    if strcmp(camID_cmp, camID_tmp)
                                        if ~isKey(tmpMap, carID_nxt)
                                            [pairMap, globalMap, tmpMap] = storePairs(carID_cur, carID_nxt, pairMap, globalMap, j, camID_tmp, search_data, t0, tmpMap, time_cur,camID);
                                        end
                                    end;
                                    clear camID_cmp;
                                end
                            end;
                            clear relatedCams;
                        end;
                    end;
                end;
            end;
            j = j-1;
            clear carID_nxt;
        end;
        
        q = pos+1;
        while searchDown == 0
            if q>=idxE || q>length(search_data)
                searchDown = 1;
                clear tmpMap;
                break;
            end;
            carID_nxt = search_data{q,1};
            timeStamp = search_data{q,3};
            flag_search=0;
            if ~isKey(tmpMap, carID_nxt)
                if ~isKey(globalMap, carID_cur)
                    flag_search=1;
                else
                    miniMap = globalMap(carID_cur);
                    if ~isKey(miniMap,timeStamp)
                        flag_search=1;
                    else
                        flag_search=0;
                    end
                end
                clear timeStamp;
                clear miniMap;
                if ~isempty(carID_nxt) && flag_search==1
                    if ~strcmp(carID_cur, carID_nxt)
                        if isKey(journeyMap,carID_nxt)
                            time = convertTime(search_data, q);
                            camID_tmp = search_data{q,4};
                            camID_tmp(camID_tmp==' ')='';
                            camID_tmp = camNameCorrection(camID_tmp);
                            if abs(time_cur - time)>threshold_delt
                                searchDown = 1;
                                clear tmpMap;
                                break;
                            end;
                            if abs(time_cur - time)<threshold_delt || abs(time_cur - time)==threshold_delt
                                if flag_mobile == 0
                                    if isKey(anprMap, camID)
                                        val = anprMap(camID);
                                        if isfield(val, 'relatedCams')
                                            relatedCams = val.relatedCams;
                                            relatedCams{length(relatedCams)+1} = camID;
                                        end
                                        if ~isfield(val, 'relatedCams')
                                            relatedCams{1} = camID;
                                        end
                                    end
                                    if ~isKey(anprMap, camID)
                                        relatedCams{1} = camID;
                                    end
                                end
                                if flag_mobile ==1
                                    relatedCams{1} = camID;
                                end
                                for idx = 1:length(relatedCams)
                                    camID_cmp = relatedCams{idx};
                                    if strcmp(camID_cmp, camID_tmp)
                                        if ~isKey(tmpMap, carID_nxt)
                                            [pairMap, globalMap, tmpMap] = storePairs(carID_cur, carID_nxt, pairMap, globalMap, q, camID_tmp, search_data, t0, tmpMap, time_cur,camID);
                                        end
                                    end;
                                    clear camID_cmp;
                                end
                            end;
                            clear relatedCams;
                        end
                    end
                end
            end
            q=q+1;
        end
    end
end

