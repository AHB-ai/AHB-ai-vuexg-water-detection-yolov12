%% Convoy Analysis
%  This function is the core of the convoy analysis, the output of this function is the extracted convoy results in a MATLAB format.

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>date</b></td><td>the date of the search query in a format of dd-mm-yyyy.</td></tr>
% <tr><td><b>anprMap</b></td><td>this is a static hash map contains essential information of ANPR camera.</td></tr>
% <tr><td><b>rawFile</b></td><td>this is the intermediate format of the ANPR reads of the input date.</td></tr>
% <tr><td><b>journey_path</b></td><td>this is the absolute path to save the journey data.</td></tr>
% <tr><td><b>convoy_path</b></td><td>this is the absolute path to save the convoy results.</td></tr>
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
% <tr><td><b>convoyMap</b></td><td>the convoy results are saved in a hashmap, the key is the combination of two VRMs. </td></tr>
% </table>
% </html>
%
%% Code
function convoyMap = getConvoyByDate(date, anprMap, rawFile, journey_path, convoy_path, session_break, num_in_session, search_window)
convoyFile = [convoy_path '\' date '_export.mat'];
journeyFile = [journey_path '\' date '_journey.mat'];
%%
% Detect if the convoy results for this specfic date is avaiable, if yes,
% load the convoy results, if not perform the following processing. 
if ~exist(convoyFile, 'file')
    %% 
    % Load intermediate data format of ANPR reads.
    disp('Loading raw data...');        
    load(rawFile);
    disp('Extracting journey information...');
    %%
    % Call function to detect if the journey information is avaiable, if not, perform
    % extraction of journey.
    % See
    % <..\html\singleJourney.html Journey Extraction>  
    [journeyMap] = singleJourney(output, journeyFile, journey_path);

    %%
    % Filter journey data using convoy size threshold to reduce the data
    % size for further processing.
    % See
    % <..\html\filterJourneyData.html Journey Filtering>
    disp('Filtering journey data...');
    dataMap = filterJourneyData(journeyMap, num_in_session);
    disp('Journey data is ready !');
    %%
    % Define session of a journey using session break threshold.
    % See
    % <..\html\singelSession.html Session Detection>
    disp('Start session detection...');
    [single_sessionMap] = singleSession(dataMap, session_break, num_in_session);
    disp('Single vehicle session data is ready !');
    %% 
    % Search vehicles travelling together for a certain period of time
    % using search window threshold. Firstly, the program will detect if
    % the parallel matlab pool is activited, if yes, parfor loop will be used
    % for parallel computing, if not, for loop will be used to conduct
    % convoy analysis.
    % See
    % <..\html\search_par.html Convoy Analysis Initiating>
    disp('Searching convoy session...');
    threshold_delt = search_window*60;
    data = output.data;
    index = output.index;
    key = keys(index);
    camMap = index(key{1});
    t0 = 734139;
    N = length(single_sessionMap);
    keySet = keys(single_sessionMap);
    pairMapList = cell(1,N);
    if isempty(gcp('nocreate'))
        for ii=1:N
            pairMapList{ii} = search_par(ii, single_sessionMap, single_sessionMap, keySet, data, t0, camMap, anprMap, threshold_delt);
        end
    else
        parfor ii=1:N
            pairMapList{ii} = search_par(ii, single_sessionMap, single_sessionMap, keySet, data, t0, camMap, anprMap, threshold_delt);
        end;
    end        
    %%
    % Final step is to filter and refile convoy result. The convoy results
    % are saved in a hash map structure, and also be saved locally. 
    % See
    % <..\html\refineConvoy.html Refining Convoy Results>
    pairMap = containers.Map('KeyType','char','ValueType','any');
    for i=1:length(pairMapList)
        map = pairMapList{i};
        key = keys(map);
        for j=1:length(key)
            pairMap(key{j}) = map(key{j});
        end
    end
    convoyMap = refineConvoy(pairMap, num_in_session, anprMap);
    save([convoy_path '\' date '_export.mat'],'convoyMap');
    disp('Convoy analysis is done.');
else
    load(convoyFile);
end
end

%% Linked Functions
% * See:
% <..\html\singleJourney.html Journey Extraction>
% * See:
% <..\html\filterJourneyData.html Journey Filtering>
% * See:
% <..\html\singelSession.html Session Detection>
% * See:
% <..\html\search_par.html Convoy Analysis Initiating>
% * See:
% <..\html\refineConvoy.html Refining Convoy Results>

%% Navigation
% * Back to 
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 


%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%
