%% Build Path
% This script search all files and save their paths in a hash map for quick access in the future.

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>pathMap</b></td><td>Hash table used to store paths</td></tr>
% <tr><td><b>dir_path</b></td><td>the path of raw ANPR data</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>pathMap</b></td><td>Hash table used to store paths</td></tr>
% </table>
% </html>
%% Code
function pathMap = build_path_map(pathMap, dir_path)

fileList = getAllFiles(dir_path);
%%
% Search for descriptor file
for i = 1:length(fileList)
    if ~isempty(strfind(fileList{i},'.xml'))
        descriptor_path = fileList{i};
    end
end
%%
% Search all files and save in a hash map, with the date is the key
for index = 1:length(fileList)
    %%
    % Descriptor file is excluded
    if isempty(strfind(fileList{index},'.xml'))
        full_path = fileList{index};
        tmp = strfind(full_path, '\');
        lg = length(tmp);
        file_name = full_path((tmp(lg)+1):end);
        
        separator = file_name(3);
        tmp = strfind(file_name, separator);
        date = file_name(1:tmp(2)+4);
        
        day = date(1:(tmp(1)-1));
        month = date((tmp(1)+1):(tmp(2)-1));
        year = date((tmp(2)+1):end);
        date_str = date2str(day, month, year);
        
        temp = isKey(pathMap, date_str);
        if temp == 0
            file_info{1} = {full_path, descriptor_path};
            pathMap(date_str)= file_info;
            clear file_path;
        end
        if temp == 1   
            tmp_file_info = pathMap(date_str);
            tmp_file_info{length(tmp_file_info)+1} = {full_path, descriptor_path};
            pathMap(date_str) = tmp_file_info;
            clear file_path;
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
