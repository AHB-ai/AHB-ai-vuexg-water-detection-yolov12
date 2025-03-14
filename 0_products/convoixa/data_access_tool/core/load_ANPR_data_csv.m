%% Index Builder
% This function loads ANPR data from a CSV (comma-separated values) file in
% order to speed up the process of loading data from excel file which is
% much slower.
% 
% If the .mat index file of the CSV file exists, this function will try to
% use it to speed up the data loading process.
%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>filename</b></td><td>file name of a CSV file which should be directly saved from the ANPR xlsx file provided by Surrey Police.</td></tr>
% <tr><td><b>rows</b></td><td>a index vecor of rows to be read (default: 'all')</td></tr>
% <tr><td><b>number_columns</b></td><td> number of files of each row of ANPR data(default: automatically detected)</td></tr>
% </table>
% </html>
%
% * OUTPUT
% 
% <html>
% <table border=2>
% <tr><td><b>data</b></td><td>2-D cell array of data in the CSV file, each of whose element is a string representing a cell in comma-separated value in the file</td></tr>
% </table>
% </html>
%
%% Code
function data = load_ANPR_data_csv(filename, rows, number_columns)

data = [];

if ~exist('filename','var')
    disp('--Please provide the file name of a CSV file as the input argument!');
    return;
end

if ~exist(filename, 'file')
    disp('------No data for this camera!');
    return;
end

fid = fopen(filename);

%%
% Automatically determine the number of columns by reading the first row of the CSV file.
if ~exist('number_columns','var')
    line = fgets(fid);
    %data = textscan(line, '%s', 'Delimiter', ',');
    %number_columns = numel(data{1});
    delimeter_num = strfind(line, ',');
    number_columns = length(delimeter_num)+1;
    frewind(fid);
end

if (~exist('rows','var') || ~isnumeric(rows))
    %%
    %
    % Read all data out of the CSV file as a string.
    % data = fread(fid, inf, '*char')';
    % Read all fields separated by commas as a 1-D column vector.
    % data = textscan(fid,'%s %s %s %s %s','delimiter',',');
    % data = textscan(data, '%s', 'Delimiter', ',');
    % The returned data is a cell array with only one element which is also a
    % cell array of strings.
    % data = data{1};
    % Find the actual number of rows with actual data.
    % row = floor(numel(data)/number_columns);
    % Remove the empty row at the end of the data.
    % data(number_columns*row+1:end) = [];
    % If further speed-up needed, the following line can also be removed or 
    % replaced by "data = data';"
    % In this case, the whole cell array will be a 1-D array representing a N x
    % number_columns data structure.
    % data = reshape(data, [number_columns row])';
    %% 
    tmpdata = [];
    
    str_separator = '';
    str_format = '%s';
    for i=1:number_columns
        str_separator = [str_separator ' ' str_format];
    end
    
    tmpdata = textscan(fid, str_separator,'delimiter',',');
    
    len = length(tmpdata{1});
    
    data = cell(len, number_columns);
    for idx=1:number_columns
        data(1:len,idx) = tmpdata{idx};
    end
else
    % Indices of rows should all be integers.
    rows = round(rows);
    % Remove invalid rows below or equal to 0.
    rows(rows<=0) = [];
    % Sort the index vector of rows so that it is increasing.
    rows = sort(rows);
    row_max = rows(end);
    % Pre-allocate space for data to ensure efficiency.
    data = cell(numel(rows), number_columns);
    % Check the index file.
    [path, name] = fileparts(filename);
    idx_filename = fullfile(path, [name '.mat']);
    if exist(idx_filename, 'file')
        % Load the index file which will create "index" variable in the
        % work space.
        load(idx_filename);
        % Remove invalid rows.
        rows(rows>numel(index)) = [];
        for i=1:numel(rows)
            fseek(fid, index(rows(i)), 'bof');
            line = fgetl(fid);
            if line==-1 % EOF, this should never happen!
                continue;
            end
            data_line = textscan(line, '%s', 'Delimiter', ',');
            %if length(data_line{1})==5
                for col=1:number_columns
                    data{i,col} = data_line{1}{col};
                end
            %end
        end
    else
        i = 1;
        for row=1:row_max
            line = fgetl(fid);
            if line==-1 % EOF
                break;
            end
            if row==rows(i)
                data_line = textscan(line, '%s', 'Delimiter', ',');
                %if length(data_line{1})==5
                    for col=1:number_columns
                        data{i,col} = data_line{1}{col};
                    end
                    i = i + 1;
                %end
            end
        end
        % If the file ends before getting all the rows, there will be some
        % empty rows at the end which should be removed.
        data(i:end,:) = [];
    end
end

fclose(fid);

end
%% Navigation
% * Go to 
% <..\html\main.html main> 
% * Go to 
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 

%% Author
%  Shujun Li & Haiyue Yuan, 02.2016, Depatment of Computer Science, University of Surrey
