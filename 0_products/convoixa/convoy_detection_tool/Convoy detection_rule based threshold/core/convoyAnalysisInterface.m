%% Convoy Analysis Interface
%  This is the interface enables the user to put search queries for convoy analysis.

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>anprMap</b></td><td>this is a static hash map contains essential information of ANPR camera.</td></tr>
% <tr><td><b>input_path</b></td><td>this is the absolute path of where stores the intermediate format of ANPR reads.</td></tr>
% <tr><td><b>journey_path</b></td><td>this is the absolute path to save the journey data.</td></tr>
% <tr><td><b>convoy_path</b></td><td>this is the absolute path to save the convoy results.</td></tr>
% <tr><td><b>date_start</b></td><td>starting date for convoy analysis.</td></tr>
% <tr><td><b>date_end</b></td><td>ending date for convoy analysis.</td></tr>
% <tr><td><b>time_start</b></td><td>starting time of the day for convoy analysis.</td></tr>
% <tr><td><b>time_end</b></td><td>ending time of the day for convoy analysis.</td></tr>
% <tr><td><b>session_break</b></td><td>this is the threshold of session break in unit of hours.</td></tr>
% <tr><td><b>num_in_session</b></td><td>this is the threshold of convoy size.</td></tr>
% <tr><td><b>search_window</b></td><td>this is the threshold of search window.</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>convoyOutput_svrm</b></td><td>The convoy results are stored in a hash map structure, the key is the single vrm.</td></tr>
% <tr><td><b>convoyOutput_dvrm</b></td><td>The convoy results are stored in a hash map structure, the key is the combination of two vrms.</td></tr>
% </table>
% </html>
%
%% Code
function [convoyOutput_svrm, convoyOutput_dvrm] = convoyAnalysisInterface(anprMap, input_path, journey_path, convoy_path, date_start,date_end, time_start, time_end, session_break, num_in_session, search_window)
t0 = 734139;
convoyOutput_svrm = containers.Map('KeyType','char','ValueType','any');
convoyOutput_dvrm = containers.Map('KeyType','char','ValueType','any');
timeNum_start = time2timeNum(time_start);
timeNum_end = time2timeNum(time_end);
%%
% Check if the path is existed.
if ~exist(input_path, 'file')
    msg = sprintf('Error, %s does not exist, please check !', dir_path);
    display(msg);
end
if ~exist(journey_path, 'file')
    mkdir(journey_path);
end
if ~exist(convoy_path, 'file')
    mkdir(convoy_path);
end

%%
% Create a list of dates according to the starting date and ending date.
dateList = getDates(date_start, date_end);
convoyList = cell(length(dateList));


%%
% Firstly detect if the paraplle MATLAB pool is active, and start to
% conduct convoy analysis using getConvoyByDate function.
% See
% <..\html\getConvoyByDate.html Convoy Analysis>
if isempty(gcp('nocreate'))
    for ii=1:length(dateList)
        date = dateList{ii};
        datestr = str2date(date);
        inputFile = [input_path '\' datestr '_export.mat'];
        if exist(inputFile, 'file')
            convoyMap = getConvoyByDate(datestr, anprMap, inputFile, journey_path, convoy_path, session_break, num_in_session, search_window);
            convoyList{ii} = {convoyMap,datestr};
        end
    end
else
    parfor ii=1:length(dateList)
        date = dateList{ii};
        datestr = str2date(date);
        inputFile = [input_path '\' datestr '_export.mat'];
        if exist(inputFile, 'file')
            convoyMap = getConvoyByDate(datestr, anprMap, inputFile, journey_path, convoy_path, session_break, num_in_session, search_window);
            convoyList{ii} = {convoyMap,datestr};
        end
    end
end


%%
% Post processing convoy results to a uniform format.
% See
% <..\html\postProcessConvoy.html Post Processing Convoy>
for j=1:length(convoyList)
    val = convoyList{j};
    if ~isempty(val)
        datestr = val{2};
        tmp = datenum(datestr, 'dd-mm-yyyy')-t0;
        dateNum = tmp*24*3600;
        clear tmp;
        convoyMap = val{1};
        [convoyOutput_svrm, convoyOutput_dvrm] = postProcessConvoy(dateNum, timeNum_start,timeNum_end, convoyOutput_svrm, convoyOutput_dvrm, convoyMap, 2);
    end
end

end

%% Linked Functions
% * See
% <..\html\getConvoyByDate.html Convoy Analysis>
% * See
% <..\html\postProcessConvoy.html Post Processing Convoy>

%% Navigation
% * Back to
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page>

%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%
