tic;
%% Convoy Analysis Tool
%  This script is a brief user guide to use Convoy Analysis Tool. It includes an example of how to use the software in MATLAB enviroment.

%% Initialise variables
% * anprMap: a static hash map contains essential information of ANPR 
% camera.
% * session_break: threshold for session break, it defines the maximum time 
% gap between two adjacent ANPR reads of a single vehicle.
% * num_in_session: threshold for convoy session size, it is the minimum
% number of cameras that two vehicles passed together in a convoy session.
% * search_window: the maximum time difference between two vehicles in a
% genuine convoy session while passing the same camera.

load anprMap;
session_break = 5; 
num_in_session = 5;
search_window = 0.5;

%%
% Session break threshold is set to be 5 hours, convoy session size is set
% to be 5, and search window threshold is set to be 30 seconds.

%% Initialise path to read and write data 
% * input_path: where to store ANPR reads
% * journey_path: where to store processed journey information
% * convoy_path: where to store extracted convoy results
% * iopath: where to store convoy results based on user search queries
parentpath = cd(cd('..'));
addpath([cd '\core']);
addpath([cd '\utility']);

input_path = [parentpath '\data.input'];
journey_path = [parentpath '\data.output\journey'];
convoy_path = [parentpath '\data.output\convoy hard threshold'];
iopath = [parentpath '\data.output\convoy hard threshold_csv'];

if ~exist(iopath, 'file')
    mkdir(iopath);
end

%% Enter search queries
% * date_start: starting date in format of dd-mm-yyyy
% * date_end: ending date in format of dd-mm-yyyy
% * time_start: starting time of the day in format of hh:mm:ss
% * time_end: ending time of the day in format of hh:mm:ss
date_start = '01-01-2020';
date_end = '03-01-2020';
time_start = '00:00:00';
time_end = '23:59:59';

%% Start convoy analysis
% Call convoyAnalysisInterface function to start convoy analysis.
% See
% <..\html\convoyAnalysisInterface.html Convoy Analysis Interface>
[convoyOutput_svrm, convoyOutput_dvrm] = convoyAnalysisInterface(anprMap, input_path, journey_path, convoy_path, date_start,date_end, time_start, time_end, session_break, num_in_session, search_window);
timestamp = datetime("now");
timestamp(timestamp==':')='';

%% Initialise output 
% * iopath_file: path to store search query 
% * iopath_csv_s: path to store convoy results that involve only two
% vehicles (2-vehicle convoy).
% * iopath_csv_r: path to store convoy results that invovle two vehilce, 
% and these two vehicles have been identified in a convoy more than once
% (repeated 2-vehicle convoy).
% * iopath_csv_m: path to store convoy results that involve more than two
% vehicles in one single convoy session (n-vehicle convoy).
iopath_file = [iopath '\' timestamp '\'];
iopath_csv_s = [iopath '\' timestamp '\csv_s\'];
iopath_csv_r = [iopath '\' timestamp '\csv_r\'];
iopath_csv_m = [iopath '\' timestamp '\csv_m\'];

%% 
% Output 2-vehicle convoy
if ~exist(iopath_csv_s, 'file')
    mkdir(iopath_csv_s);
end
outputConvoyCSV(iopath_csv_s, convoyOutput_dvrm);

%% 
% Conduct analysis to identify repeated 2-vehicle convoy, and output it.
% See
% <..\html\extractRepeatedConvoyPairs.html Repeated Convoy Analysis>
repeatedConvoy = extractRepeatedConvoyPairs(convoyOutput_dvrm);
if ~exist(iopath_csv_r, 'file')
    mkdir(iopath_csv_r);
end
outputRepeatedConvoyCSV(iopath_csv_r, repeatedConvoy);

%% 
% Conduct analysis to identify n-vehicle convoy, and output it.
% See
% <..\html\extractMultipleVehicleConvoy.html N-vehicle Convoy Analysis>
threshold_session_num = 3;
multipleVehicleConvoy = extractMultipleVehicleConvoy(convoyOutput_svrm, 3, anprMap, convoy_path);
if ~exist(iopath_csv_m, 'file')
    mkdir(iopath_csv_m);
end
outputMultipleConvoy(iopath_csv_m, multipleVehicleConvoy);
%% 
% Output search query
if ~exist(iopath_file, 'file')
    mkdir(iopath_file);
end
textFile = [iopath_file 'search_query.txt'];
fid=fopen(textFile,'w');
fprintf(fid, [date_start ' ' date_end ' ' time_start ' ' time_end ' ' num2str(session_break) ' ' num2str(num_in_session) ' ' num2str(search_window) '\n']);
fclose(fid);

%% Linked Functions
% * See:
% <..\html\convoyAnalysisInterface.html Convoy Analysis Interface>
% * See:
% <..\html\extractRepeatedConvoyPairs.html Repeated Convoy Analysis>
% * See:
% <..\html\extractMultipleVehicleConvoy.html N-vehicle Convoy Analysis>

%% Navigation
% * Go to 
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 
%%
% <<..\polarbear.png>>

%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
toc;