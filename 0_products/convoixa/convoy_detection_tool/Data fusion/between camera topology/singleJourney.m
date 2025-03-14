% This script is to scan all reads and save journey data of one single
% vehicle per day.
% INPUT:
% -inputData: intermediate format of ANPR data
% -output_dir: output directory to store the results
% Haiyue@Jun 2015

function [journeyMap] = singleJourney(inputData, output_dir)
load(inputData);
if ~exist(output_dir, 'file')
    mkdir(output_dir);
end
disp('Start scanning all reads...');
tic;
data = output.data;
date_string = data{1,2};
journeyMap = containers.Map('KeyType','char','ValueType','any');
for j=1:length(data)
    carID = data{j,1};
    datestr = data{j,2};
    try
        dateNum = datenum(datestr, 'dd-mm-yyyy')-734139;
        sectmp = str2num(strrep(data{j,3},':', ' '));
        timeNum =  dateNum*24*3600+sectmp(1)*3600+sectmp(2)*60+sectmp(3);
        camID = data{j,4};
        coords = data{j,5};
        realTime = [data{j,2} ' ' data{j,3}];
        dataInfo.time = timeNum;
        dataInfo.realTime = realTime;
        dataInfo.camID = camID;
        dataInfo.pos = j;
        dataInfo.coords = coords;
        tf = isKey(journeyMap, carID);
        if tf==0
            dataList{1} = dataInfo;
            journeyMap(carID) = dataList;
            clear dataInfo;
            clear dataList;
        end
        if tf==1
            dataList_tmp = journeyMap(carID);
            length_tmp = length(dataList_tmp);
            if (dataList_tmp{length_tmp}.time~=dataInfo.time)
                dataList_tmp{length_tmp+1} = dataInfo;
            end
            journeyMap(carID) = dataList_tmp;
            clear dataInfo;
            clear dataList;
        end
    catch
    end
end
%clear output;
%save([output_dir '\' date_string '_journey.mat'],'journeyMap');
