
%% Conversion
% This script converts raw ANPR data to intermediate data by calling the
% following functions:
%
% * Convert the raw data in xlxs format to csv format
% * Build index for quick access
% * Convert csv data to matlab structure data
%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>date</b></td><td>date of raw ANPR data needs to be converted</td></tr>
% <tr><td><b>path_lists</b></td><td>paths of raw ANPR data and its corresponding intermediate format descriptor</td></tr>
% <tr><td><b>inter_folder</b></td><td>path to store intermediate format data</td></tr>
% <tr><td><b>interfile</b></td><td>the intermediate file that describes the format of converted data.</td></tr>
% </table>
% </html>
%
% * OUTPUT
% 
% <html>
% <table border=2>
% <tr><td><b>output</b></td><td>converted ANPR data in MATLAB data structure</td></tr>
% </table>
% </html>
%
%% Code

function [output_data] = convertRaw(date, path_lists, inter_folder, interfile)

for id = 1:length(path_lists)
    %%
    % Get all paths of raw ANPR data and intermediate format descriptor
    file_path = path_lists{id}{1};
    dsfile = path_lists{id}{2};
    %%
    % Load and read descriptor
    % See:
    % <..\html\loadDSXML.html Read Descriptor>
    datasource = loadDSXML(dsfile);
    outputfile = generateOutputFile(file_path,inter_folder);
    %%
    % Convert raw data
    % See: 
    % <..\html\fileConverter.html File Conveter>
    fileConverter(datasource, file_path, interfile, outputfile, str2date(date));
end
input_date = str2date(date);
[~, name] = fileparts(file_path);
num = strfind(name, 'READS');
if ~isempty(num)
    datetmp = name(1:num-2);
else 
    datetmp = name;
end
mergeCSVs([inter_folder '\'], datetmp);
output_file = [inter_folder '\' input_date '.csv'];

%%
% Build index to fast access
% See:
% <..\html\load_ANPR_data_csv.html Index Builder>
fprintf('--Start to build index file for ''%s'':\n', output_file);
build_csv_index(output_file);
output_data = load_ANPR_data_csv(output_file, 'all', 9);

for id = 1:length(path_lists)
    file_path = path_lists{id}{1};
    outputfile = generateOutputFile(file_path,inter_folder);
    delete(outputfile);
end

end

%% Linked Functions
% * See:
% <..\html\loadDSXML.html Read Descriptor>
% * See:
% <..\html\fileConverter.html File Conveter>
% * See:
% <..\html\load_ANPR_data_csv.html Index Builder>

%% Navigation
% * Go to 
% <..\html\main.html main> 
% * Go to 
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 

%% Author
%  Haiyue Yuan, 02.2016, Depatment of Computer Science, University of Surrey

