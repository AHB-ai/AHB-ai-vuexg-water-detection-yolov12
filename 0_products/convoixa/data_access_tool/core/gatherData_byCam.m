%% Retrieve Data by Camera Group
% This script is to gather data based on the camera groups and dates, and then convert the data to matlab data structure (new_data). In the mean time, it keeps the information of how the data stores in the matlab data structure (dateMap) in order to quick access in a later stage.

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>date</b></td><td>the request date for conversion</td></tr>
% <tr><td><b>output_folder</b></td><td>the path to store the converted ANPR data, and intermediate data</td></tr>
% <tr><td><b>camList</b></td><td>is used to organise data by camera group</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>new_data</b></td><td>retrieved data in MATLAB structure</td></tr>
% <tr><td><b>dateMap</b></td><td>a hash map stores index file corresponding to the converted data</td></tr>
% </table>
% </html>
%
%% Code

function [new_data, dateMap] = gatherData_byCam(camList, date, output_folder)
disp('--Gathering data based on camera group...');
    dateMap = containers.Map('KeyType','char','ValueType','any');
    camMap = containers.Map('KeyType','char','ValueType','any');
    data_list = cell(length(camList),1);
    %%
    % As the data is sorted by the camera group and then be stored in the
    % whole dataset, for each camera group, there are two indexes, one indicates the
    % starting position in the whole data set, and another one indicates
    % the ending position in the whole data set. This can help to quick
    % access for further usage.
    idxS = 0;
    for id=1:length(camList)
        camName = camList{id};
        file = [output_folder '\' camName '\' str2date(date) '.csv'];
        message = ['---Processing ANPR camera ', camName, ' data...'];
        disp(message)
        tmpdata = load_ANPR_data_csv(file, 'all', 9);
        if ~isempty(tmpdata)
            data = sortrows(tmpdata,3);
            data_list{id} = data;
            idxS = idxS + 1;
            lenD = length(data);
            idxE = idxS + lenD;
            val_tmp = {idxS, idxE};
            camMap(camName) = val_tmp;
            idxS = idxE;
            clear val_tmp;
        end
        
    end
    dateMap(str2date(date)) = camMap;
clear idx;
clear id;

tmp_data = data_list{1};
for id=2:length(data_list)
    tmp_data = [tmp_data; data_list{id}];
end
new_data = tmp_data;

%% Navigation
% * Go to 
% <..\html\main.html main> 
% * Go to 
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 

%% Author
%  Haiyue Yuan, 02.2016, Depatment of Computer Science, University of Surrey



