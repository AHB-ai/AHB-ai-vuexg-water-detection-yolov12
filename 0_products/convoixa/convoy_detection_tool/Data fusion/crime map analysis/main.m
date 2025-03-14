% Example usage
% load crime map data to matlab data format
dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\crime map analysis\data1';
[crimeMap] = crimeMap2struct(dir_path);

% check crime statistics given a month, a ANPR ID and a search radius and
% generate report.
output_dir = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\crime map analysis\output';
month = '2015-03';
anprId = 'ANPR1.10';
searchRadius = 5;
load('anprMap.mat');
[crimeStats] = checkCrimeStats(month, anprId, crimeMap, anprMap, searchRadius, output_dir);
