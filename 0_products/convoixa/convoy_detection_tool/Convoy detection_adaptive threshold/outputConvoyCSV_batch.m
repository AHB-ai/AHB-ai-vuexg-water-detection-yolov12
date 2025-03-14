% iopath = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Convoy Analysis\convoy algorithm\output data\convoy_output_hard_threshold_CSV'
% dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Convoy Analysis\convoy algorithm\output data\convoy_output_hard_threshold'
function list = outputConvoyCSV_batch(iopath, dir_path, ref_path, timewindow, anprMap, sizeMap, topologyStats)
list = {};
count=1;
t0 = 734139;
fileList = getAllFiles(dir_path);
for idx = 1:length(fileList)
    file = fileList{idx};
    [~, name, ~] = fileparts(file);
    tmp = strfind(name,'_');
    date = name(1:tmp(1)-1);
    load(file);
    keySet = keys(convoyMap);
    for i=1:length(keySet)
        key = keySet{i};
        dataset = convoyMap(key);
        ct=1;
        if ~isempty(dataset)
            val = dataset{1};
            [height, width] = size(val);

            % add adaptive session break to results
            for n=1:2:height-2
                ANPR1 = val{n,3};
                ANPR2 = val{n+2,3};
                flag1 = strfind(ANPR1,'ANPR');
                flag2 = strfind(ANPR2,'ANPR');
                if ~isempty(flag1) && ~isempty(flag2) && isKey(anprMap, ANPR1) && isKey(anprMap, ANPR2)
                    dateNum = (datenum(date, 'dd-mm-yyyy')-734139)*24*3600;
                    timeNum = val{n,2} - dateNum;
                    [data] = retrieveTravelTime(ANPR1, ANPR2, ref_path, date, anprMap, timeNum, timewindow);
                    if isempty(data)
                        session_break = 0;
                    else
                        session_break = detectSessionBreak(data,100,0.9);
                    end
                else
                    session_break = 0;
                end
                travel_time = val{n+2,2} - val{n,2};
                if session_break==0
                    val{n,width+1} = 0;
                     val{n,width+2} = travel_time;
                else
                    %%% ADD NEW FORMAT FOR NEW REPRESENTATION OF ADAPTIVE
                    %%% SESSION BREAK
                    if session_break<=60 || travel_time <= session_break
                        val{n,width+1} = 0;
                        val{n,width+2} = travel_time;
                        %val{n,width+3} = session_break;
                    else
                        val{n,width+1} = 1;
                        %val{n,width+2} = travel_time;
                        val{n,width+2} = session_break;
                        list{count} = {date,key};
                        count = count+1;
                    end
                end
                %display(val{n,width+1});
            end
            clear ANPR1;
            clear ANPR2;
            clear flag1;
            clear flag2;
            clear session_break;
            clear dateNum;
            clear timeNum;
            clear height;
            clear width;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % add adaptive session size to results
            [height, width] = size(val);
            camId = val{1,3};
            timeNum = val{1,2};
            day = getDayOfWeek(timeNum);
            sessionSizeMap = sizeMap(day);
            if isKey(sessionSizeMap,camId)
                journey_size = sessionSizeMap(camId)+1;
            else
                journey_size = 4;
            end
            val{1,width+1} = height/2;
            val{2,width+1} = journey_size;
            clear journey_size;
            clear height;
            clear width;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % add probablity between cameras to results
            [height, width] = size(val);
            for n=1:2:height-2
                ANPR1 = val{n,3};
                ANPR2 = val{n+2,3};
                prob = getProbability(ANPR1, ANPR2, anprMap, topologyStats);
%                 camLink = [ANPR1 ' ' ANPR2];
%                 if isKey(topologyStats,camLink)
%                     prob = topologyStats(camLink);
%                 else
%                     if isKey(anprMap, ANPR1)
%                         val = anprMap(ANPR1);
%                     end
%                     prob = 0;
%                 end
                val{n,width+1} = prob;
                clear prob;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % conver time format to a human readable format
            for n=1:height
                datetime = val{n,2};
                time_str = datestr(t0+datetime/86400);
                val{n,2} = time_str;
            end
            for n=1:height
                pair_write(ct,:) = val(n,:);
                ct=ct+1;
            end
        end
        new_path = [iopath '\' date];
        if ~exist(new_path, 'file')
            mkdir(new_path);
        end
        new_file = [new_path '\' key '.csv'];
        simplemat2csv(pair_write, new_file);
        clear pair_write;
        clear ct;
    end
end


end