% scan all ANPR reads by dates, and generate travel time data
dir_path = '..\converted ANPR reads';
output_dir = '..\traffic time estimation from ANPR reads\traffic_output';
getTravelTime(dir_path, output_dir);

% get travel time between 2 ANPR cameras, between 2 dates, and a certain
% period of time of the day.
ANPR1 = 'ANPR08.35';
ANPR2 = 'ANPR08.36';
date_start = '01-05-2015';
date_end = '25-05-2015';
time_start = '00:00:00';
time_end = '23:59:59';
dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\traffic_output';
output_dir = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\output';
results_stats = trafficAnalysis_novrm(dir_path, date_start, date_end, time_start, time_end, ANPR1, ANPR2, output_dir);

% get travel time for a specfic vrm between 2 ANPR cameras, between 2 dates, and a certain
% period of time of the day.
vrm = '3BC4D267FE45D5728B57B1B656B99AEC';
ANPR1 = 'ANPR13.3';
ANPR2 = 'ANPR14.1';
date_start = '01-03-2015';
date_end = '15-03-2015';
time_start = '00:00:00';
time_end = '23:59:59';
dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\traffic_output';
output_dir = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\output';
results_stats = trafficAnalysis_vrm(dir_path, vrm, date_start, date_end, time_start, time_end, ANPR1, ANPR2, output_dir);

% VERSION 2
dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Convoy Analysis\convoy algorithm\output data\output_journey';
output_dir = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\traffic_output';
if ~exist(output_dir, 'file')
    mkdir(output_dir);
end
dir = [output_dir '\travel time_no vrm_v2'];
if ~exist(dir, 'file')
    mkdir(output_dir, 'travel time_no vrm_v2');
end

fileList = getAllFiles(dir_path);
parfor ii=1:length(fileList)
    tic;
    display(ii);
    file = fileList{ii};
    getTravelTime_v2(file, dir);
    toc;
end

dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\traffic_output\travel time_no vrm_v2';
fileList = getAllFiles(dir_path);
output_dir = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\output_v4';
%for ii=1:length(fileList)
parfor ii=1:length(fileList)
    tic;
    display(ii);
    file = fileList{ii};
    gatherTrafficTime_v2(file, output_dir)
    toc;
end


dir_path = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\traffic_output\travel time_no vrm_v2';
fileList = getAllFiles(dir_path);
output_dir_1 = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\output_v4';
output_dir_2 = 'C:\Users\hy0006\Project\POLARBEAR.WP2\Data fusion\traffic time estimation from ANPR reads\output_v5';
for ii=1:length(fileList)
    tic;
    display(ii);
    file = fileList{ii};
    gatherTrafficTime_v3(file, output_dir_1,output_dir_2);
    toc;
end

