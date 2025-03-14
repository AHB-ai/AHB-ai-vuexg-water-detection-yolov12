%
% This script is used to merge csv files according to the date of files.
% The Surrey Police BOF data have multiple files for a single date.
% Input Argument:
% folder path: select the folder that contains csv files need to be merged.
% date: enter the date (dd-mm-yyyy)that all csv files have the same date
% need to be converted into a single csv file (date: 'default' for convert
% all files in this folder)
% Output: a single csv file contains all data collected at the same date.
% Haiyue @Dec 2014

function mergeCSVs(folder_path, date)
% load directory and get the number of files
mapObj = containers.Map('KeyType','char','ValueType','any');
csv_files = dir(fullfile(folder_path,'*.csv'));
n = numel(csv_files);
fileList = {};
if n==0
    fprintf('The chosen folder is empty, there is no csv file within this folder, please select another folder!\n');
end

if n>0
    if exist([folder_path date '.csv'], 'file')
    else
        if ~strcmp(date, 'default')
            for i=1:n
                filename = csv_files(i).name;
                num = strfind(filename, 'READS');
                if ~isempty(num)
                    filedate = filename(1:num-2);
                    if strcmp(date, filedate)
                        tf = isKey(mapObj,filedate);
                        if tf ==0
                            fileList{1} = [folder_path '\' csv_files(i).name];
                            mapObj(filedate) = fileList;
                        end
                        if tf ==1
                            fileListlength = length(mapObj(filedate));
                            fileListIndex = fileListlength+1;
                            fileList_tmp = mapObj(filedate);
                            fileList_tmp{fileListIndex} = [folder_path '\' csv_files(i).name];
                            mapObj(filedate) = fileList_tmp;
                        end
                        %end
                        clear filedate;
                    end
                end
            end
            tmp = size(mapObj);
            if tmp(1)==0
                fprintf('Please enter the correct date !!!');
            end
            if tmp(1)>0
                keySet = keys(mapObj);
                tmpKey = keySet{1};
                fileList = mapObj(tmpKey);
                col1 = cell(length(fileList),1);
                col2 = cell(length(fileList),1);
                col3 = cell(length(fileList),1);
                col4 = cell(length(fileList),1);
                col5 = cell(length(fileList),1);
                col6 = cell(length(fileList),1);
                col7 = cell(length(fileList),1);
                col8 = cell(length(fileList),1);
                col9 = cell(length(fileList),1);
                for j=1:length(fileList)
                    fid = fopen(fileList{j});
                    out = textscan(fid,'%s %s %s %s %s %s %s %s %s','delimiter',',');
                    col1{j,1} = out{1};
                    col2{j,1} = out{2};
                    col3{j,1} = out{3};
                    col4{j,1} = out{4};
                    col5{j,1} = out{5};
                    col6{j,1} = out{6};
                    col7{j,1} = out{7};
                    col8{j,1} = out{8};
                    col9{j,1} = out{9};
                    fclose(fid);
                end

                % merge files with same date into one single file
                len_prev = 0;
                
                for m = 1:length(col1)
                    len_tmp = length(col1{m,1});
                    startIdx = len_prev+1;
                    tempData(startIdx:startIdx+len_tmp-1, 1)= col1{m,1}(1:len_tmp, 1);
                    tempData(startIdx:startIdx+len_tmp-1, 2)= col2{m,1}(1:len_tmp, 1);
                    tempData(startIdx:startIdx+len_tmp-1, 3)= col3{m,1}(1:len_tmp, 1);
                    tempData(startIdx:startIdx+len_tmp-1, 4)= col4{m,1}(1:len_tmp, 1);
                    tempData(startIdx:startIdx+len_tmp-1, 5)= col5{m,1}(1:len_tmp, 1);
                    tempData(startIdx:startIdx+len_tmp-1, 6)= col6{m,1}(1:len_tmp, 1);
                    tempData(startIdx:startIdx+len_tmp-1, 7)= col7{m,1}(1:len_tmp, 1);
                    tempData(startIdx:startIdx+len_tmp-1, 8)= col8{m,1}(1:len_tmp, 1);
                    tempData(startIdx:startIdx+len_tmp-1, 9)= col9{m,1}(1:len_tmp, 1);
                    len_prev = len_prev + len_tmp;
                end
                
                % Sort the data according to the ANPR capture time
                % column 3 is the time column according to the data descriptor.
                sortedData = sortrows(tempData,3);
                
                % transfer data structure in order to save it as csv file
                [m n] = size(sortedData);
                Data = cell(m,n+n-1);
                Data(:,1:2:end) = sortedData;
                Data(:,2:2:end,:) = {','};
                Data = arrayfun(@(i) [Data{i,:}], 1:m, 'UniformOutput',false)';
                
                separator = tmpKey(3);
                tmp = strfind(tmpKey, separator);
                day = tmpKey(1:(tmp(1)-1));
                month = tmpKey((tmp(1)+1):(tmp(2)-1));
                year = tmpKey((tmp(2)+1):end);
                dateFormat = date2str2(day, month, year);
                
                foutput = fopen([folder_path '\' dateFormat '.csv'],'wt');
                fprintf(foutput, '%s\n', Data{:});
                fclose(foutput);
                %fclose(fid);
                clear sortedData;
                clear tempData;
                clear col1;
                clear col2;
                clear col3;
                clear col4;
                clear col5;
                clear len_prev;
                clear startIdx;
            end
        end
    end
end
end


