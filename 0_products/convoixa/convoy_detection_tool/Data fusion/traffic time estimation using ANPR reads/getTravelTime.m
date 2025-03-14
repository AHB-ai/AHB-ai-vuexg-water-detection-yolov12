% This script is to go through ANPR data day by day and save the travel time
% between ANPR cameras as a separate file according to its date,
% and also save a hashmap that contains VRMs with its individual record of
% travel time
% INPUT:
% - dir_path: is the path where save all the intermediate format of ANPR data
% (this should be ..\converted ANPR reads)
% - output_folder: is the path where to save the output of this function
% Haiyue@Jun 2015
function getTravelTime(dir_path, output_folder)
if ~exist(output_folder, 'file')
    mkdir(output_folder);
end
dir1 = [output_folder '\travel time_vrm'];
if ~exist(dir1, 'file')
    mkdir(output_folder, 'travel time_vrm');
end
dir2 = [output_folder '\travel time_no vrm'];
if ~exist(dir2, 'file')
    mkdir(output_folder, 'travel time_no vrm');
end

fileList = getAllFiles(dir_path);
for i=1:3
    display(i);
    tic;
    file = fileList{i};
    [~,name,~] = fileparts(file);
    tmp = strfind(name, '_');
    date = name(1:tmp(1)-1);
    output_file1 = [dir1 '\' date '_vrm.mat'];
    output_file2 = [dir1 '\' date '_traffic.mat'];
    if ~exist(output_file1,'file') && ~exist(output_file2,'file')
        load(file);
        vrmMap = containers.Map('KeyType','char','ValueType','any');
        data = output.data;
        sortedData = sortrows(data,3);
        date = sortedData{1,2};
        dateTmp = datenum(date, 'dd-mm-yyyy')-734139;
        dateNum = dateTmp*24*3600;
        clear data;
        
        for j=1:length(sortedData)
            carID = sortedData{j,1};
            try
                sectmp = str2num(strrep(sortedData{j,3},':', ' '));
                timeStr = sortedData{j,3};
                timeNum = sectmp(1)*3600+sectmp(2)*60+sectmp(3);
                %%trim potential space%%
                camIDtmp = sortedData{j,4};
                tmp1 = strfind(camIDtmp, 'ANPR');
                if ~isempty(tmp1)
                    camIDtmp = camIDtmp(tmp1:end);
                    tmp2 = strfind(camIDtmp, ' ');
                    if ~isempty(tmp2)
                        camID = camIDtmp(1:tmp2-1);
                    end
                    if isempty(tmp2)
                        camID = camIDtmp;
                    end
                end
                if isempty(tmp1)
                    camID = camIDtmp;
                end
                %%%%
                %coords = sortedData{j,5};
                dataInfo.timeStr = timeStr;
                dataInfo.time = dateNum + timeNum;
                dataInfo.camID = camID;
                %dataInfo.coords = coords;
                tf = isKey(vrmMap, carID);
                if tf==0
                    dataList{1} = dataInfo;
                    vrmMap(carID) = dataList;
                end
                if tf==1
                    dataList_tmp = vrmMap(carID);
                    length_tmp = length(dataList_tmp);
                    if (dataList_tmp{length_tmp}.time~=dataInfo.time)
                        dataList_tmp{length_tmp+1} = dataInfo;
                    end
                    vrmMap(carID) = dataList_tmp;
                end
            catch
            end
        end
        disp('Scanning is done !');
        toc;
        
        tic;
        disp('Processing...');
        keyVrm = keys(vrmMap);
        vrm_trafficMap = containers.Map('KeyType','char','ValueType','any');
        trafficMap = containers.Map('KeyType','char','ValueType','any');
        %for m = 1:10000
        for m = 1:length(keyVrm)
            %display(m);
            carID = keyVrm{m};
            infoJourney = vrmMap(carID);
            if length(infoJourney)>1
                loc_trafficMap = containers.Map('KeyType','char','ValueType','any');
                for n=1:(length(infoJourney)-1)
                    camID = infoJourney{n}.camID;
                    time = infoJourney{n}.time;
                    timeStr = infoJourney{n}.timeStr;
                    camID_nxt = infoJourney{n+1}.camID;
                    time_nxt = infoJourney{n+1}.time;
                    time_dif = time_nxt - time;
                    camKey = [camID ' ' camID_nxt];
                    flag1 = isKey(trafficMap, camKey);
                    flag2 = isKey(loc_trafficMap, camKey);
                    if flag1==0
                        timeArray{1,1} = time;
                        timeArray{1,2} = time_dif;
                        timeArray{1,3} = timeStr;
                        trafficMap(camKey) = timeArray;
                    end
                    if flag1==1
                        timeArray = trafficMap(camKey);
                        sizeArray = size(timeArray);
                        len = sizeArray(1);
                        timeArray{len+1,1} = time;
                        timeArray{len+1,2} = time_dif;
                        timeArray{len+1,3} = timeStr;
                        trafficMap(camKey) = timeArray;
                    end
                    if flag2==0
                        loc_timeArray{1,1} = time;
                        loc_timeArray{1,2} = time_dif;
                        loc_timeArray{1,3} = timeStr;
                        loc_trafficMap(camKey) = loc_timeArray;
                    end
                    if flag2==1
                        loc_timeArray = loc_trafficMap(camKey);
                        loc_sizeArray = size(loc_timeArray);
                        loclen = loc_sizeArray(1);
                        loc_timeArray{loclen+1,1} = time;
                        loc_timeArray{loclen+1,2} = time_dif;
                        loc_timeArray{loclen+1,3} = timeStr;
                        loc_trafficMap(camKey) = loc_timeArray;
                    end
                    clear timeArray;
                    clear loc_timeArray;
                end
                vrm_trafficMap(carID) = loc_trafficMap;
                clear loc_trafficMap;
            end
        end
        
        save([dir1 '\' date '_vrm.mat'],'vrm_trafficMap');
        save([dir2 '\' date '_traffic.mat'],'trafficMap');
        clear vrmMap;
        clear trafficMap;
        clear sortedData;
        clear vrm_trafficMap;
        disp('Finished !');
        toc;
        %clear all;
    end
end
disp('All finished !');
end

