
% Haiyue@Feb 2015
function fileList = getAllFiles(dir_path)

% Get the data for the current directory
dirData = dir(dir_path);
% Find the index for directories
dirIndex = [dirData.isdir];
% Get a list of the files
fileList = {dirData(~dirIndex).name}';
% Prepend path to files
if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dir_path,x),...
        fileList,'UniformOutput',false);
end
% Get a list of the subdirectories
subDirs = {dirData(dirIndex).name};
% Find index of subdirectories
%   that are not '.' or '..'
validIndex = ~ismember(subDirs,{'.','..'});

% Loop over valid subdirectories
for iDir = find(validIndex)
    % Get the subdirectory path
    nextDir = fullfile(dir_path,subDirs{iDir});
    % Recursively call getAllFiles
    fileList = [fileList; getAllFiles(nextDir)];
end

end