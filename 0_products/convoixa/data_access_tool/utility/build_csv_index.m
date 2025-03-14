function index = build_csv_index(filename)
% index = build_csv_index(filename)
% This function builds an index file of a given CSV file to speed up
% random access of data at any row.
% The index file is a MATLAB data file (.mat) with the same file name as
% the CSV file, containing a 1-D vector of the file offset of each row in
% the CSV file.
% Given the index file, one can use fseek() function to achieve fast random
% access to data in the CSV file.
%
% Input argument:
% filename: file name of a CSV file which should be directly saved
%           from the ANPR xlsx file provided by Surrey Police.
%
% Output argument:
% index: the index vector stored in the index file.
%
% Author: Shujun Li @ www.hooklee.com 2013

index = [];

if ~exist('filename','var')
    disp('Please provide the file name of a CSV file as the input argument!');
    return;
end

if ~exist(filename, 'file')
    disp('The CSV file does not exist!');
    return;
end

fid = fopen(filename);

% Scan the whole file to get the number of rows.
number_rows = 0;
while ~feof(fid)
    line = fgetl(fid);
    if line~=-1
        number_rows = number_rows + 1;
    end
end
frewind(fid);

% Pre-allocate space to avoid efficiency.
index = zeros(1, number_rows);
for row=1:number_rows
    fgetl(fid);
    index(row) = ftell(fid);
end

fclose(fid);

[path, name] = fileparts(filename);
save(fullfile(path, [name '.mat']), 'index');

end
