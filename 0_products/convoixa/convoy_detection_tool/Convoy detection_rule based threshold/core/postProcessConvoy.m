%% Post Processing Convoy Results
%  This is the function to post process the convoy results.

%%
%% I/O
% * INPUT:
%
% <html>
% <table border=2>
% <tr><td><b>dateNum</b></td><td>this is the converted format for date.</td></tr>
% <tr><td><b>timeNum_start</b></td><td>this is the converted format for starting time for search query.</td></tr>
% <tr><td><b>timeNum_end</b></td><td>this is the converted format for ending time for search query.</td></tr>
% <tr><td><b>convoyOutput_svrm</b></td><td>this is the empty hash map to store convoy results with key of single vrm.</td></tr>
% <tr><td><b>convoyOutput_dvrm</b></td><td>this is the empty hash map to convoy results with key of combination of two vrms.</td></tr>
% <tr><td><b>convoyMap</b></td><td>this is the convoy results obtained using getConvoyByDate</td></tr>
% <tr><td><b>minimum_anprId</b></td><td>this is minimum number of different ANPR existed in a convoy session.</td></tr>
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
function [convoyOutput_svrm, convoyOutput_dvrm] = postProcessConvoy(dateNum, timeNum_start, timeNum_end, convoyOutput_svrm, convoyOutput_dvrm, convoyMap, minimum_anprId)
%%
% To get the starting time and ending time 
minTime = dateNum + timeNum_start;
maxTime = dateNum + timeNum_end;

%%
% Store convoy results in two different hash maps.
keySet = keys(convoyMap);
for j=1:length(keySet)
    key = keySet{j};
    flag = strfind(key,' ');
    vrm1 = key(1:flag(1)-1);
    vrm2 = key(flag(1)+1:end);
    temp = convoyMap(key);
    val = temp{1};
    [h,~]=size(val);
    tmptime_start = val{1,2};
    tmptime_end = val{h,2};
    if tmptime_start>=minTime && tmptime_end<=maxTime
        stats = temp{2};
        num_cams = stats(5,4);
        if num_cams>minimum_anprId
            if ~isKey(convoyOutput_dvrm, key)
                results{1} = {val,stats};
                convoyOutput_dvrm(key) = results;
                clear results;
            else
                results = convoyOutput_dvrm(key);
                results{length(results)+1} = {val,stats};
                convoyOutput_dvrm(key) = results;
                clear results;
            end
            if ~isKey(convoyOutput_svrm, vrm1)
                results{1} = {val,stats};
                convoyOutput_svrm(vrm1) = results;
                clear results;
            else
                results = convoyOutput_svrm(vrm1);
                results{length(results)+1} = {val,stats};
                convoyOutput_svrm(vrm1) = results;
                clear results;
            end
            if ~isKey(convoyOutput_svrm, vrm2)
                results{1} = {val,stats};
                convoyOutput_svrm(vrm2) = results;
                clear results;
            else
                results = convoyOutput_svrm(vrm2);
                results{length(results)+1} = {val,stats};
                convoyOutput_svrm(vrm2) = results;
                clear results;
            end
        end
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
