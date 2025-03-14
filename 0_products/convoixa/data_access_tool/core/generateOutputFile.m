% This script is to produce unified name for converted csv data. 
% Haiyue @Jan 2015

function outputfile = generateOutputFile(file_path, output_folder)

[~, name] = fileparts(file_path);
outputfile = fullfile(output_folder, [name '.csv']);

% separator = name(3);
% tmp = strfind(name, separator);
%         %date1 = file_name(1:tmp(2)+2);
% date = name(1:tmp(2)+4);        
% day = date(1:(tmp(1)-1));
% month = date((tmp(1)+1):(tmp(2)-1));
% year = date((tmp(2)+1):end);
% file = date2str2(day, month, year);
%         
% outputfile = fullfile(output_folder, [file '.csv']);
end