%% Journey Filtering
%  This function is to filer the journey data to reduce the data size for further processing.

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>journeyMap</b></td><td>input hash map stores journey information for each vehicle.</td></tr>
% <tr><td><b>journey_size</b></td><td>this is the convoy size threshold.</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>dataMap</b></td><td>this is output of filtering journey data. </td></tr>
% </table>
% </html>
%
%% Code
function dataMap = filterJourneyData(journeyMap, journey_size)
%%
% Filtering journey map based on the size of the journey 
dataMap = containers.Map('KeyType','char','ValueType','any');
keySet = keys(journeyMap);
for i = 1:length(keySet)
   vrm = keySet{i};
   val = journeyMap(vrm);
   if length(val)>journey_size 
       dataMap(vrm) = val;
   end
end
dataMap = filterDataMap(dataMap, 2);

%% 
% Further filtering journey map based on the minimum number of different
% ANPR camers within the journey
function dataMap = filterDataMap(dataMap, min_cam)
keySet = keys(dataMap);
for i=1:length(keySet)
    val = dataMap(keySet{i});
    camIdMap = containers.Map('KeyType','char','ValueType','any');
    for j=1:length(val)
        camId = val{j}.camID;
        if ~isKey(camIdMap, camId)
            camIdMap(camId) = 1;
        else
            num = camIdMap(camId);
            camIdMap(camId) = num+1;
        end
    end
    if length(camIdMap) < min_cam
        remove(dataMap, keySet{i});
    end
end

%% Navigation
% * Back to 
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 

%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%