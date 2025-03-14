%% Organise Data by Camera Group
% This script is to organise the data and distribute the data according
% to its camera groups, it formulates a physical layer of data index based
% on camera groups
% 
%% Code
function organiseDataByCam(data_slicer, input_data, date, output_folder)

    data = input_data;

    % Cut the data into small pieces to speed up the whole proces
    number = floor(length(data)/data_slicer);
    mod_number = mod(length(data), data_slicer);
    mapArray = cell(number+1,1);
    % Load the whole data, and create corresponding directory according
    % to the camera group

    for idx = 1:number
        camMap = containers.Map('KeyType','char','ValueType','any');
        for j = ((idx-1)*(data_slicer)+1):idx*data_slicer
            tmpName = data{j,4};
            tmp = strfind(tmpName,'.');
            if isempty(tmp)
                camName = 'Mobile Unit';%['Mobile Unit\' tmpName(1:(tmp1(1)-1))];
            end
            if ~isempty(tmp)
                if strcmp(tmpName(1:4), 'ANPR')
                    if tmp(1)==6
                        camName = ['ANPR0' tmpName(tmp(1)-1)];
                    end
                    if tmp(1)>6
                        camName = tmpName(1:(tmp(1)-1));
                    end
                end
            end
            num = isKey(camMap, camName);
            if num == 0
                data_by_cam = cell(1,9);
                data_by_cam(1,:) =  data(j,:);
                dir = [output_folder '\' camName];
                if ~exist(dir, 'file')
                    mkdir(output_folder,camName);
                end
                camMap(camName) = data_by_cam;
            end
            if num == 1
                data_by_cam = camMap(camName);
                size_data = size(data_by_cam);
                row = size_data(1);
                data_by_cam(row+1,:) =  data(j,:);
                camMap(camName) = data_by_cam;
            end
        end
        mapArray{idx} = camMap;
        clear camMap;
    end
    camMap = containers.Map('KeyType','char','ValueType','any');
    for j = ((number)*(data_slicer)+1):((number)*(data_slicer)+mod_number)
        tmpName = data{j,4};
        tmp = strfind(tmpName,'.');
        if isempty(tmp)
            camName = 'Mobile Unit';
        end
        if ~isempty(tmp)
            if strcmp(tmpName(1:4), 'ANPR')
                if tmp(1)==6
                    camName = ['ANPR0' tmpName(tmp(1)-1)];
                end
                if tmp(1)>6
                    camName = tmpName(1:(tmp(1)-1));
                end
            end
        end
        
        num = isKey(camMap, camName);
        if num == 0
            data_by_cam = cell(1,9);
            data_by_cam(1,:) =  data(j,:);
            dir = [output_folder '\' camName];
            if ~exist(dir, 'file')
                mkdir(output_folder,camName);
            end
            camMap(camName) = data_by_cam;
        end
        if num == 1
            data_by_cam = camMap(camName);
            size_data = size(data_by_cam);
            row = size_data(1);
            data_by_cam(row+1,:) =  data(j,:);
            camMap(camName) = data_by_cam;
        end
        %end
    end
    mapArray{number+1} = camMap;
    clear camMap;
 
    % File i/o to write into file as csv format.
    mapsize = size(mapArray);
    row = mapsize(1);
    for id=1:row
        tmpMap = mapArray{id};
        if ~isempty(tmpMap)
            keySet = keys(tmpMap);
            for jd=1:length(keySet)
                camName = keySet{jd};
                dir = [output_folder '\' camName];
                file = [dir '\' str2date(date) '.csv'];
                if exist(file, 'file')
                    fid = fopen(file, 'a+');
                end
                if ~exist(file, 'file')
                    fid = fopen(file, 'wt');
                end
                data_by_cam = tmpMap(camName);
                datasize = size(data_by_cam);
                datarow = datasize(1);
                for md=1:datarow
                    fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s,%s \n',data_by_cam{md,:});
                end
                fclose(fid);
            end
        end
    end
%% Navigation
% * Go to 
% <..\html\main.html main> 
% * Go to 
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 

%% Author
%  Haiyue Yuan, 02.2016, Depatment of Computer Science, University of Surrey
