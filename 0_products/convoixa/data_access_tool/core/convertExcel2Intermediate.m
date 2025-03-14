%% Conversion Interface
%  This is the interface enables the user to put search queries for converting raw ANPR data.

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>data_dir</b></td><td>the path of raw ANPR data from Data wharehouse</td></tr>
% <tr><td><b>jar_dir</b></td><td>the path of external java library</td></tr>
% <tr><td><b>date_start</b></td><td>the starting date for converting raw ANPR data</td></tr>
% <tr><td><b>date_end</b></td><td>the ending date for converting raw ANPR data</td></tr>
% <tr><td><b>output_dir</b></td><td>the path to store the converted ANPR data, and intermediate data</td></tr>
% <tr><td><b>camList</b></td><td>is used to organise data by camera group</td></tr>
% <tr><td><b>interfile</b></td><td>the intermediate file that describes the format of converted data.</td></tr>
% </table>
% </html>
%
%% Code

function convertExcel2Intermediate(data_dir, jar_dir, date_start, date_end, output_dir, camList, interfile, data_slicer)
%%
% Build hash map to store path information for further quick access
% See
% <..\html\build_path_map.html Build Path>
pathMap = containers.Map('KeyType','char','ValueType','any');
pathMap = build_path_map(pathMap, data_dir);
results_folder = [output_dir '\converted ANPR reads'];
if ~exist(results_folder, 'file')
    mkdir(output_dir, 'converted ANPR reads');
end
%%
% Add paths of external java library to MATLAB environment
importJAR([jar_dir '\']);
%% 
% Define path to store intermediate data
inter_folder = [output_dir '\intermediate'];
if ~exist(inter_folder, 'file')
    mkdir(output_dir, 'intermediate');
end
camGroup_folder =  [output_dir '\camera groups'];
if ~exist(camGroup_folder, 'file')
    mkdir(output_dir, 'camera groups');
end
%%
% Get all dates between starting date and ending date of search
dateList = getDates(date_start, date_end);
length_dateList = length(dateList);
%%
for i=1:length_dateList
    date = dateList{i};
    if ~isempty(date)
        fprintf("Converting data for %s: \n", date);
        if isKey(pathMap, date)
            path_lists = pathMap(date);
            idx_file = fullfile(inter_folder, [str2date(date) '.mat']);
            csv_file = fullfile(inter_folder, [str2date(date) '.csv']);
            %%
            % Detect if the index file and intermediate file exists, and
            % call the corresponding functions to convert raw data
            if exist(idx_file, 'file') && exist(csv_file, 'file')
                %%
                % If the index file and intermediate file exists, call
                % gatherData_byCam to retrieve data.
                % See
                % <..\html\gatherData_byCam.html Retrieve Data by Camera Group>
                [new_data, dateMap] = gatherData_byCam(camList, date, camGroup_folder);
            end
            if ~exist(idx_file, 'file') || ~exist(csv_file, 'file')
                %%
                % If the index file or intermediate file does not exist,
                % the program calls three functions to convert the data.
                % The program calls convertRaw to convert the data, and
                % followed by calling organiseDataByCam to organise the
                % data by its camera group for quick access, and lastly the
                % program calls gatherData_byCam to retrieve data
                % See:
                % <..\html\convertRaw.html Conversion;>
                % See:
                % <..\html\organiseDataByCam.html Organise Data by Camera Group;>
                % See:
                % <..\html\gatherData_byCam.html Retrieve Data by Camera Group.>
                [output_data] = convertRaw(date, path_lists, inter_folder, interfile);
                organiseDataByCam(data_slicer, output_data, date, camGroup_folder)
                [new_data, dateMap] = gatherData_byCam(camList, date, camGroup_folder);
            end
            %%
            % Save the output to the dedicated path
            output = struct;
            output.data = new_data;
            output.index = dateMap;
            save_path = [results_folder '\' str2date(date) '_export.mat'];
            save(save_path,'output');
            message = ['Conversion is completed, please check ', save_path];
            disp(message);
            clear output;
        else
            fprintf('Sorry there is no data for this date: ''%s'' in the database',date);
        end
    end
end
end

%% Linked Functions
% * See
% <..\html\build_path_map.html Build Path>
% * See:
% <..\html\convertRaw.html Conversion>
% * See:
% <..\html\organiseDataByCam.html Organise Data by Camera Group>
% * See:
% <..\html\gatherData_byCam.html Retrieve Data by Camera Group>

%% Navigation
% * Go to 
% <..\html\main.html main> 
% * Go to 
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 

%% Author
%  Haiyue Yuan, 02.2016, Depatment of Computer Science, University of Surrey

