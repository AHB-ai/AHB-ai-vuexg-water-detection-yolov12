% This script is to scan all reads and save journey data of one single
% vehicle per day.
% INPUT:
% -inputData: intermediate format of ANPR data
% -output_dir: output directory to store the results
% Haiyue@Sep 2015

function [journeyMap] = singleJourney(output, output_dir)
if ~exist(output_dir, 'file')
    mkdir(output_dir);
end
data = output.data;
date_string = data{1,2};
dateNum = datenum(date_string, 'dd-mm-yyyy')-734139;
journeyMap = containers.Map('KeyType','char','ValueType','any');
for j=1:length(data)
    carID = data{j,1};
    if ~isempty(carID)
        sectmp = str2num(strrep(data{j,3},':', ' '));
        timeNum =  dateNum*24*3600+sectmp(1)*3600+sectmp(2)*60+sectmp(3);
        camID = data{j,4};
        dataInfo.time = timeNum;
        dataInfo.camID = camID;
        dataInfo.pos = j;
        if ~isKey(journeyMap, carID);
            dataList{1} = dataInfo;
            journeyMap(carID) = dataList;
            clear dataInfo;
            clear dataList;
        else
            dataList_tmp = journeyMap(carID);
            length_tmp = length(dataList_tmp);
            if (dataList_tmp{length_tmp}.time~=dataInfo.time)
                dataList_tmp{length_tmp+1} = dataInfo;
            end
            dataList_tmp = sortJourney(dataList_tmp);
            journeyMap(carID) = dataList_tmp;
            clear dataInfo;
            clear dataList;
        end    
    end
end
%journeyMap = sortJourneyMap(journeyMap);
save([output_dir '\' date_string '_journey.mat'],'journeyMap');
