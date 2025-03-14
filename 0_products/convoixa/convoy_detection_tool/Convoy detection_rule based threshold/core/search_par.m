%% Convoy Analysis Initiating
%  This function initiate the convoy analysis and call the search function
%  to conduct convoy analysis

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>index</b></td><td>this is the index of the position in a hash map structure that stores session data of all vehicle. An index is poining at a particular vehicle.</td></tr>
% <tr><td><b>single_sessionMap</b></td><td>this is the hash map structure store session data.</td></tr>
% <tr><td><b>dataMap</b></td><td></td></tr>
% <tr><td><b>keySet</b></td><td> this is a list that contains all vrms.</td></tr>
% <tr><td><b>search_data</b></td><td>this is the dataset to be searched, it contains all ANPR reads in intermediate format.</td></tr>
% <tr><td><b>t0</b></td><td></td></tr>
% <tr><td><b>camMap</b></td><td>this contains the starting position and ending position for each camera group in the intermediate format of ANPR reads. The aim of using this is to accerlerate the speed of processing.</td></tr>
% <tr><td><b>anprMap</b></td><td></td></tr>
% <tr><td><b>threshold_delt</b></td><td>this is the threshold of search window in seconds.</td></tr>
% </table>
% </html>
%
% * OUTPUT:
%
% <html>
% <table border=2>
% <tr><td><b>pairMap</b></td><td>this is the hash map structure stores all convoy search results. </td></tr>
% </table>
% </html>
%
%% Code
function [pairMap] = search_par(index, single_sessionMap, dataMap, keySet, search_data, t0, camMap, anprMap, threshold_delt)
pairMap = containers.Map('KeyType','char','ValueType','any');
carID_cur = keySet{index};
if ~isempty(carID_cur)
    session_cur = single_sessionMap(carID_cur);
    for k = 1:length(session_cur)
        if ~isempty(session_cur{k})
            for m = 1:length(session_cur{k})
                %%
                % Get information of time stamp, camera ID, vehicle make, model, color and tax code
                time_cur = session_cur{k}{m}.time;
                pos = session_cur{k}{m}.pos;
                camID = search_data{pos,4};
                camID(camID==' ')='';
                camID = camNameCorrection(camID);
                tmp = strfind(camID, '.');
                make = search_data{pos,6};
                model = search_data{pos,7};
                color = search_data{pos,8};
                tax = search_data{pos,9};                               
                %%
                % Search for vehicles travelling in convoy.
                % See
                % <..\html\performConvoySearch.html Search for Convoy>
                flag_mobile = 0;
                if isempty(tmp)
                    camKey = 'Mobile Unit';
                    flag_mobile = 1;
                end
                if ~isempty(tmp)
                    if strcmp(camID(1:4), 'ANPR')
                        if tmp(1)==6
                            camKey = ['ANPR0' camID(tmp(1)-1)];
                        end
                        if tmp(1)>6
                            camKey = camID(1:(tmp(1)-1));
                        end
                        flag_mobile = 0;
                    end
                end
                val = camMap(camKey);
                idxS = val{1};
                idxE = val{2};
                pos = session_cur{k}{m}.pos;
                [pairMap] = performConvoySearch(carID_cur, camID, dataMap, threshold_delt, pairMap, pos, idxS, idxE, search_data, time_cur, make, model, color, tax, flag_mobile, t0, anprMap);                
            end;
        end;
    end;
end;
%% Linked Functions
% * See
% <..\html\performConvoySearch.html Search for Convoy>

%% Navigation
% * Back to 
% <..\html\main.html Convoy Analysis Tool>
% * Go to
% <http://www.surrey.ac.uk/cs/research/msf/projects/polarbear_pattern_of_life_anpr_behaviour_extraction_analysis_and_recognition.htm Project page> 


%% Author
%  Haiyue Yuan, 01.2016, Depatment of Computer Science, University of Surrey
%%