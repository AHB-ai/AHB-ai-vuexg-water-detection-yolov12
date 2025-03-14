%% Data Access Tool
%  This script is a brief user guide to use Data Acess Tool. It includes an example of how to use the software in MATLAB enviroment.
%  The conversion of the raw ANPR data can be a dayily routine work.

%% Initialise variables
% * data_dir: the path of raw ANPR data from Data wharehouse
% * jar_dir: the path of external java library
% * date_start: the starting date for converting raw ANPR data
% * date_end: the ending date for converting raw ANPR data
% * output_dir: the path to store the converted ANPR data, and intermediate
% data.
% * camList.mat: is used to organise data by camera group
% * interfile: it is the intermediate file that describes the format of
% converted data.

parentpath = cd(cd('..'));
addpath([cd '/core']);
addpath([cd '/utility']);
addpath([cd '/java lib']);

jar_dir = [cd '/java lib'];
date_start = '01-01-2020'; % Please change these two dates based on your purpose
date_end = '03-01-2020';
output_dir = [cd '/output'];
load('camList.mat'); % This is included in the tool package, it records all location information for all ANPR cameras.

interfile = [cd '/intermediate_format.xml'];

data_dir = [cd '/raw data']; % Example: this is where store the raw ANPR reads

data_slicer = 10000; % This is used to split the data into small chunks to speed up the procesing speed
                   % Increase this number for a file with larger size,
                   % 10000 was used for excel file that contains around 1 million reads
                 

%% Start Conversion Process
convertExcel2Intermediate(data_dir, jar_dir, date_start, date_end, output_dir, camList, interfile, data_slicer);

%% Linked Functions
% * See:
% <..\html\convertExcel2Intermediate.html Conversion Interface>

%% Navigation
% * Go to 
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 
%%
% <<..\polarbear.png>>

%% Author
%  Haiyue Yuan, 09.2023, School of Computing, University of Kent

