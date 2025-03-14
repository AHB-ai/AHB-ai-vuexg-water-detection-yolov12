% This script is to output the results of travel time based on the search
% criterias.
% Please note that this function support to search data between two dates within
% certain time of the day.
% INPUT:
% - dir_path: is the path where store all the raw between cameras travel time data.
% - date_start: search data by exact dates. This is the start date. (Example: date_start = '01-03-2015')
% - date_end: search data by exact dates. This is the end date. (Example: date_end = '01-04-2015')
% - time_start: use together with search data by exact dates. Can be left
% as empty (Example: time_start = ''), or user can indicate a exact time.(Example: time_start = '10:30:15')
% - time_end: use together with search data by exact dates. Can be left
% as empty (Example: time_end = ''), or user can indicate a exact time.(Example: time_end = '14:30:15')
% -ANPR1 and ANPR2 are the camera name (Example: ANPR1 = 'ANPR1.10', ANPR2 = 'ANPR1.11')
% -output is the path of the output csv file
% OUTPUT:
% -results_stats: is a cell array that contains all the results.
% The first column is the unix timestamps(start from 01/01/2010). The
% second column is the travel time in seconds. The third column is the
% real time.
% Haiyue@Jun 2015

function results_stats = trafficAnalysis_novrm(dir_path, date_start, date_end, time_start, time_end, ANPR1, ANPR2, output_dir)
disp('Start processing...');
if ~exist(output_dir, 'file')
    mkdir(output_dir);
end
flag_empty_date = 0;
flag_wrong_date = 0;
flag_wrong_anpr = 0;
t0 = 734139; % number for 01-01-2010
ts = 0;
te = 23*3600+59*60+59;
tic;
results_stats = {};
% Convert time from string to number
if ~isempty(time_start)
    sectmp = str2num(strrep(time_start,':', ' '));
    time_startNum_const = sectmp(1)*3600+sectmp(2)*60+sectmp(3);
    clear sectmp;
end
if isempty(time_start)
    time_startNum_const = 0*3600+0*60+0;
    clear sectmp;
end
if ~isempty(time_end)
    sectmp = str2num(strrep(time_end,':', ' '));
    time_endNum_const = sectmp(1)*3600+sectmp(2)*60+sectmp(3);
    clear sectmp;
end
if isempty(time_end)
    time_endNum_const = 23*3600+59*60+59;
    clear sectmp;
end
% Convert date from string to number
if isempty(date_start) || isempty(date_end)
    %display('Please enter the correct date for searching');
    flag_empty_date = 1;
end
temp_results = {};
if ~isempty(date_start) && ~isempty(date_end)
    date_start = dateConvert(date_start,'dd-mm-yyyy','yyyy-mm-dd');
    date_end = dateConvert(date_end,'dd-mm-yyyy','yyyy-mm-dd');
    tmpList = cellstr(datestr(datenum(date_start)+1:datenum(date_end),'yyyy-mm-dd'));
    dateList = cell(1, length(tmpList));
    dateList{1} = date_start;
    for i=1:length(tmpList)
        if ~isempty(tmpList{i})
            dateList{i+1} = tmpList{i};
        end
    end    
    for i=1:length(dateList)
        date = dateList{i};
        date = dateConvert(date,'yyyy-mm-dd','dd-mm-yyyy');
        dateTmp = datenum(date, 'dd-mm-yyyy')-t0;
        dateNum = dateTmp*24*3600;
        time_startNum = time_startNum_const+dateNum;
        time_endNum = time_endNum_const+dateNum;
        file = [dir_path '\travel time_no vrm\' date '_traffic.mat'];
        load(file);
        camKey = [ANPR1 ' ' ANPR2];
        flag = isKey(trafficMap,camKey);
        if flag==1
            stats = trafficMap(camKey);
            if time_startNum_const == ts && time_endNum_const == te
                temp = stats;
            end
            if time_startNum_const ~= ts || time_endNum_const ~= te
                sz = size(stats);
                count=1;
                temp = {};
                for m=1:sz(1)
                    timeNum = stats{m,1};
                    if timeNum<=time_endNum
                        if timeNum>=time_startNum
                            temp{count,1} = timeNum;
                            temp{count,2} = stats{m,2};
                            count = count+1;
                        end
                    end
                end
            end
            if ~isempty(temp)
                temp_results = [temp_results; temp];
            end
            flag_wrong_anpr = 0;
        end
        if flag==0
            flag_wrong_anpr = 1;
        end
        clear trafficMap;
    end        
end
if isempty(temp_results)
    if flag_wrong_date ==1
        disp('Error ! Search date and time are incorrect, please check !');
    end
    if flag_empty_date ==1
        disp('Error ! Search dates are missing, please check !');
    end
    if flag_wrong_anpr ==1
        disp('Error ! Can not find travel time between these two ANPR cameras, please check !');
    end
    disp('No results are found based on the search criteria');
end
if ~isempty(temp_results)
    temp_results = sortrows(temp_results,1);
    results_stats = sortrows(temp_results,1);
    sz = size(results_stats);
    for i=1:sz(1)
        unixtime = results_stats{i,1};
        real_time = datestr(t0+unixtime/86400);
        results_stats{i,3} = real_time;
    end
    clear stats;
    clear temp_results;
    output_file = [output_dir '\' ANPR1 ' ' ANPR2 ' ' date_start '-' date_end '.csv'];
    simplemat2csv(results_stats, output_file);
end
toc;
disp('Done!');
end