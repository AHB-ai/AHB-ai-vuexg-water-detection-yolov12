%% Journey Extraction
%  This script is to scan all reads and save journey data of one single vehicle per day.

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>input_data</b></td><td>ANPR reads in an intermediate format.</td></tr>
% <tr><td><b>output_dir</b></td><td>path to store journey data.</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>journeyMap</b></td><td>the journey is stored in a hash map sturcture, with key of a single vehicle's vrm. </td></tr>
% </table>
% </html>
%
%% Code

function [journeyMap] = singleJourney(input_data, journeyFile, output_dir)
if ~exist(journeyFile, 'file')
    t0 = 734139;
    if ~exist(output_dir, 'file')
        mkdir(output_dir);
    end
    data = input_data.data;
    date_string = data{1,2};
    dateNum = datenum(date_string, 'dd-mm-yyyy')-t0;
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
    save([output_dir '\' date_string '_journey.mat'],'journeyMap');
else
    load(journeyFile)
end

%% Navigation
% * Back to
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page>


%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%